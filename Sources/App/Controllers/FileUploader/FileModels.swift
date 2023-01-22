//
//  FileUploaderModel.swift
//  
//
//  Created by Vladyslav Vdovychenko on 22.01.2023.
//

import Vapor

struct FileUploaderModel: Content {
    var files: [File]
    var quality: ImageProcessingQuality?
}

struct FileDownloaderModel: Content {
    var id: String
}
