//
//  PhotogrammetryService.swift
//  
//
//  Created by Vladyslav Vdovychenko on 22.01.2023.
//

import Metal
import RealityKit
import Vapor
import CoreImage
import CoreVideo

protocol PhotogrammetryService {
    var selectedQuality: ImageProcessingQuality { get set }
    var finalModelURL: URL? { get }
    var currentProgress: Double? { get }
    var storedError: Error? { get }
    
    func initObjectCaptureSession(with files: [File]) throws -> UUID
}

class PhotogrammetryServiceImplementation: PhotogrammetryService {
    
    // MARK: - Public variables
    
    var selectedQuality: ImageProcessingQuality = .reduced
    var finalModelURL: URL?
    var currentProgress: Double?
    var storedError: Error?
    
    // MARK: - Private variables
    
    private var inputFolderURL: URL?
    
    // MARK: - Public methods
    
    public func initObjectCaptureSession(with files: [File]) throws -> UUID {
        guard supportsObjectCapture else {
            throw Abort(.badRequest)
        }
        
        let id = try initialiseDirectory(for: files)
        
        Task {
            try await startSession(with: id)
        }
        
        return id
    }
    
}

private extension PhotogrammetryServiceImplementation {
    
     /// Checks to make sure at least one GPU meets the minimum requirements for object reconstruction. At least one GPU must be a "high power" device, which means it has at least 4 GB of RAM, provides barycentric coordinates to the fragment shader, and is running on a Mac with Apple silicon, or on an Intel-based Mac with a discrete GPU.
    var supportsObjectReconstruction: Bool {
        for device in MTLCopyAllDevices() where
            !device.isLowPower &&
             device.areBarycentricCoordsSupported &&
             device.recommendedMaxWorkingSetSize >= UInt64(4e9) {
            return true
        }
        return false
    }

    /// Returns `true` if at least one GPU has hardware support for ray tracing. The GPU that supports ray tracing need not be the same GPU that supports object reconstruction.
    var supportsRayTracing: Bool {
        for device in MTLCopyAllDevices() where device.supportsRaytracing {
            return true
        }
        return false
    }

    /// Returns `true` if the current hardware supports Object Capture.
    var supportsObjectCapture: Bool {
        return supportsObjectReconstruction && supportsRayTracing
    }
    
    func startSession(with id: UUID) async throws {
        guard let inputFolderURL = inputFolderURL else {
            throw Abort(.badRequest)
        }
        
        let outputURL = inputFolderURL.appendingPathComponent("\(id.uuidString).usdz")
        let session = try PhotogrammetrySession(input: inputFolderURL)
        let request = PhotogrammetrySession.Request.modelFile(url: outputURL,
                                                              detail: selectedQuality.photogrammetryQuality)
        
        try session.process(requests: [request])
        
        try performSessionOutputs(session)
    }
    
    func initialiseDirectory(for files: [File]) throws -> UUID {
        let id = UUID()
        let inputFolderUrl = URL(fileURLWithPath: NSTemporaryDirectory(),
                                 isDirectory: true).appendingPathComponent(id.uuidString,
                                                                           isDirectory: true)
        
        try FileManager.default.createDirectory(atPath: inputFolderUrl.path,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
        
        for file in files {
            let fileUrl = inputFolderUrl.appendingPathComponent(file.filename)
            try Data(buffer: file.data).write(to: fileUrl)
        }
        
        inputFolderURL = inputFolderUrl
        
        return id
    }
    
    func performSessionOutputs(_ session: PhotogrammetrySession) throws {
        Task {
            for try await output in session.outputs {
                switch output {
                case .requestProgress(let request, let fraction):
                    currentProgress = fraction
                    print("Progress: \(fraction)")
                    
                case .requestComplete(let request, let result):
                    switch result {
                    case .modelFile(let url):
                        finalModelURL = url
                        print("Result output at \(url)")
                        
                    default:
                        break
                    }
                    
                case .requestError(let request, let error):
                    storedError = error
                    print("Request \(request) get error \(error)")
                    
                case .processingComplete:
                    print("Completed!")
                default:
                    break
                }
            }
        }
    }
    
}

fileprivate extension ImageProcessingQuality {
    
    var photogrammetryQuality: PhotogrammetrySession.Request.Detail {
        switch self {
        case .preview:
            return .preview
        case .reduced:
            return .reduced
        case .medium:
            return .medium
        case .full:
            return .full
        case .raw:
            return .raw
        }
    }
    
}
