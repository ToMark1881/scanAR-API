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
        // print("Session from request \(request). Started.")
        
        let model = try request.content.decode(FileUploaderModel.self)
        let service = PhotogrammetryServiceImplementation()
        
        if let quality = model.quality {
            service.selectedQuality = quality
        }
        
        let id = try service.initObjectCaptureSession(with: model.files)
        
        services[id.uuidString] = service
        
        return id.uuidString
    }
    
    func getProgress(with request: Request, webSocket: WebSocket) async throws -> () {
        guard let id = request.query[String.self, at: "id"],
              let service = services[id] else {
            try await webSocket.send("Job failed!")
            try await webSocket.close(code: .normalClosure)
            throw Abort(.badRequest)
        }
        
        class LastProgress {
            static var value: Int = 0
        }
        
        let repeatedTask = request.eventLoop.scheduleRepeatedTask(initialDelay: .zero, delay: .seconds(1)) { _ in
            Task {
                if let error = service.storedError {
                    try await webSocket.send("Job failed!")
                    try await webSocket.close(code: .normalClosure)
                    throw Abort(.custom(code: 400, reasonPhrase: error.localizedDescription))
                }
                
                if service.finalModelURL != nil {
                    try await webSocket.send("Job complete")
                    try await webSocket.close(code: .normalClosure)
                } else if let progress = service.currentProgress {
                    let roundedProgress = Int(progress * 100)
                    if LastProgress.value < roundedProgress {
                        try await webSocket.send("\(roundedProgress)%")
                        LastProgress.value = roundedProgress
                    }
                }
            }
        }
        
        webSocket.onClose.whenComplete { _ in
            repeatedTask.cancel()
        }
    }
    
    func downloadGeneratedModel(with request: Request) throws -> Response {
        guard let id = request.query[String.self, at: "id"] else {
            throw Abort(.badRequest)
        }
                
        guard let service = services[id] else {
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
