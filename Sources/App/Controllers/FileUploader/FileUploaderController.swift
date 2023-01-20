//
//  File.swift
//  
//
//  Created by Vladyslav Vdovychenko on 20.01.2023.
//

import Vapor

class FileUploaderController {
    
    public func processUploadRequest(_ request: Request) async -> String {
        return "Working!"
    }
    
    public func processInitRequest(_ request: Request) async throws -> String {
        let selectedQuality = try request.content.decode(ImageProcessingQualityModel.self)
        
        return "You have chosen \(selectedQuality.quality.rawValue) quality"
    }
    
}
