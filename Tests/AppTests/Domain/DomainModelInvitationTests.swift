@testable import Domain
import Foundation
import NIO

import XCTest

final class DomainModelInvitationTests: XCTestCase, HasEntityTestSupport, HasAllTests {

    static var __allTests = [
        ("testProperties", testProperties),
        ("testAllTests", testAllTests)
    ]

    typealias EntityType = Invitation

    func testProperties() throws {
        entityTestProperties()
    }

    func testAllTests() throws {
        assertAllTests()
    }

}
