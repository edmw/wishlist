@testable import App
import Vapor
import Fluent

import XCTest

class ListTests: XCTestCase, EntityTestsSupport {
    typealias EntityType = List

    func testProperties() {
        entityTestProperties()
    }

}
