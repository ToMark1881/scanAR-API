//
//  PhotogrammetryManager.swift
//  
//
//  Created by Vladyslav Vdovychenko on 22.01.2023.
//

import Vapor

class PhotogrammetryManager {
    
    static let shared = PhotogrammetryManager()
    
    var services: [String: PhotogrammetryService] = [:]
    
    private init() {  }
    
    func initPhotogrammetrySession(with request: Request) async throws -> String {
        let model = try request.content.decode(FileUploaderModel.self)
        let service = PhotogrammetryServiceImplementation()
        
        if let quality = model.quality {
            service.selectedQuality = quality
        }
        
        let id = try service.initObjectCaptureSession(with: model.files)
        
        services[id.uuidString] = service
        
        return id.uuidString
    }
    
    func downloadGeneratedModel(with request: Request) async throws -> Response {
        let model = try request.content.decode(FileDownloaderModel.self)
        
        guard let service = services[model.id] else {
            throw Abort(.internalServerError)
        }
        
        if let error = service.storedError {
            throw Abort(.custom(code: 400, reasonPhrase: error.localizedDescription))
        }
        
        guard let finalUrl = service.finalModelURL else {
            throw Abort(.internalServerError)
        }
        
        return request.fileio.streamFile(at: finalUrl.path)
    }
    
}
