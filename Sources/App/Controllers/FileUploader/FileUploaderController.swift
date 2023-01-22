//
//  FileUploaderController.swift
//  
//
//  Created by Vladyslav Vdovychenko on 20.01.2023.
//

import Vapor

class FileUploaderController {
    
    private lazy var manager: PhotogrammetryManager = { .shared }()
    
    public func processUploadRequest(_ request: Request) async throws -> String {
        let result = try await manager.initPhotogrammetrySession(with: request)
        
        return result
    }
    
    public func processDownloadRequest(_ request: Request) async throws -> Response {
        let result = try await manager.downloadGeneratedModel(with: request)
        
        return result
    }
    
}
