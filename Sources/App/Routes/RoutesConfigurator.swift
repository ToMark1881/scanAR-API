import Vapor

public class RoutesConfigurator {
    
    // MARK: - Public
    public func registerRoutes(_ app: Application) throws {
        try registerFileUploadingRoute(app)
        try registerFileDownloadRoute(app)
        try registerHealthRoute(app)
    }
    
    // MARK: - Private
    private func registerFileUploadingRoute(_ app: Application) throws {
        app.on(.POST, "upload-photos", body: .collect(maxSize: "1gb")) { request async throws -> String in
            let controller = FileUploaderController()
            let result = try await controller.processUploadRequest(request)
            
            return result
        }
    }
    
    private func registerFileDownloadRoute(_ app: Application) throws {
        app.on(.GET, "download-model") { request -> Response in
            let controller = FileUploaderController()
            let result = try await controller.processDownloadRequest(request)
            
            return result
        }
    }
    
    private func registerHealthRoute(_ app: Application) throws {
        app.on(.GET, "health-check") { request -> String in
            return "I am alive!"
        }
    }
}
