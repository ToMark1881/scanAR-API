//
//  File.swift
//  
//
//  Created by Vladyslav Vdovychenko on 20.01.2023.
//

import Vapor

class FileUploaderController {
    
    private lazy var service: PhotogrammetryService = { PhotogrammetryService() }()
    
    public func processUploadRequest(_ request: Request) async throws -> String {
        let model = try request.content.decode(FileUploaderInput.self)
        
        if let quality = model.quality {
            service.selectedQuality = quality
        }
        
        let id = try service.initObjectCaptureSession(with: model.files)
        
        return id.uuidString
    }
    
}

fileprivate struct FileUploaderInput: Content {
    var files: [File]
    var quality: ImageProcessingQuality?
}
