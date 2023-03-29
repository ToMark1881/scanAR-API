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
    
    public func processProgressRequest(_ request: Request, socket: WebSocket) async throws -> () {
        try await manager.getProgress(with: request, webSocket: socket)
    }
    
    public func processDownloadRequest(_ request: Request) throws -> Response {
        let result = try manager.downloadGeneratedModel(with: request)
        
        return result
    }
    
}
