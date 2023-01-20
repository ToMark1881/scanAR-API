@testable import App
import XCTVapor

final class AppTests: XCTestCase {
    
    func testHealthCheck() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try AppConfigurator.configure(app)

        try app.test(.GET, "health-check", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "I am alive!")
        })
    }
    
}
