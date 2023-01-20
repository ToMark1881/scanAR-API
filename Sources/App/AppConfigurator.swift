import Vapor

public class AppConfigurator {
    
    public class func configure(_ app: Application) throws {
        let routesConfigurator = RoutesConfigurator()
        
        try routesConfigurator.registerRoutes(app)
    }
    
}
