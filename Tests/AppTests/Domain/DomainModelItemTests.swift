@testable import Domain
import Foundation
import NIO

import XCTest

final class DomainModelItemTests: XCTestCase, HasEntityTestSupport, HasAllTests {

    static var __allTests = [
        ("testProperties", testProperties),
        ("testAllTests", testAllTests)
    ]

    typealias EntityType = Item

    func testProperties() throws {
        entityTestProperties()
    }

    func testAllTests() throws {
        assertAllTests()
    }

}
