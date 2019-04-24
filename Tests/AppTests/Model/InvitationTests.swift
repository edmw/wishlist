@testable import App
import Vapor
import Fluent

import XCTest

class InvitationTests: XCTestCase, EntityTestsSupport {
    typealias EntityType = Invitation

    func testProperties() {
        entityTestProperties()
    }

}
