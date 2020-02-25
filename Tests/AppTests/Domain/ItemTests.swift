@testable import App
@testable import Domain
import Foundation
import NIO

import XCTest
import Testing

final class ItemTests: XCTestCase, HasEntityTestSupport, HasAllTests {

    static var __allTests = [
        ("testProperties", testProperties),
        ("testAllTests", testAllTests)
    ]

    typealias EntityType = Item
    typealias ModelType = FluentItem

    func testProperties() throws {
        entityTestProperties()
    }

    func testAllTests() throws {
        assertAllTests()
    }

}
