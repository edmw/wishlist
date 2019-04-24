@testable import App
import Vapor
import Fluent

import XCTest

class ItemTests: XCTestCase, EntityTestsSupport {
    typealias EntityType = Item

    func testProperties() {
        entityTestProperties()
    }

}
