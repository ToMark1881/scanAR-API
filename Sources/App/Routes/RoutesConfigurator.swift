import Vapor

public class RoutesConfigurator {
    
    // MARK: - Public
    public func registerRoutes(_ app: Application) throws {
        try registerFileUploadingRoute(app)
        try registerFileUploaderInitRoute(app)
        try registerHealthRoute(app)
    }
    
    // MARK: - Private
    private func registerFileUploadingRoute(_ app: Application) throws {
        app.on(.POST, "upload-photos", body: .collect(maxSize: "1gb")) { request async throws -> String in
            let controller = FileUploaderController()
            let result = await controller.processUploadRequest(request)
            
            return result
        }
    }
    
    private func registerFileUploaderInitRoute(_ app: Application) throws {
        app.on(.POST, "uploader-quality") { request async throws -> String in
            let controller = FileUploaderController()
            let result = try await controller.processInitRequest(request)
            
            return result
        }
    }
    
    private func registerHealthRoute(_ app: Application) throws {
        app.on(.GET, "health-check") { request -> String in
            return "I am alive!"
        }
    }
}
