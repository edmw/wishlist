@testable import App
import Vapor
import VaporTestTools

extension Application {

    static func testable() throws -> Application {
        Environment.dotenv()

        return try! TestableProperty.new(
            env: Environment.detect(),
                { con, env, ser in try! App.configure(&con, &env, &ser) }
        ) { (router) in }
    }

}
