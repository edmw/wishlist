@testable import App
@testable import Domain
import Foundation
import NIO

import XCTest
import Testing

final class ListTests: XCTestCase, AppTestCase, HasEntityTestSupport, HasAllTests {

    static var __allTests = [
        ("testProperties", testProperties),
        ("testAllTests", testAllTests)
    ]

    typealias EntityType = List
    typealias ModelType = FluentList

    func testProperties() throws {
        entityTestProperties()
    }

    func testAllTests() throws {
        assertAllTests()
    }

}
