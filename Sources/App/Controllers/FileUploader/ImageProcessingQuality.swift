//
//  ImageProcessingQuality.swift
//  
//
//  Created by Vladyslav Vdovychenko on 20.01.2023.
//

import Foundation

enum ImageProcessingQuality: String, Codable {
    case preview, reduced, medium, full, raw
}

struct ImageProcessingQualityModel: Decodable {
    let quality: ImageProcessingQuality
    
    private enum CodingKeys: String, CodingKey {
        case quality
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.quality = try container.decode(ImageProcessingQuality.self, forKey: .quality)
    }
}
