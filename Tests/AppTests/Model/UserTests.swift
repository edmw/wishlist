@testable import App
import Vapor
import Fluent

import XCTest

class UserTests: XCTestCase, EntityTestsSupport {
    typealias EntityType = User

    func testProperties() {
        entityTestProperties()
    }

}
