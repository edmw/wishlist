@testable import Domain
import Foundation
import NIO

import XCTest
import Testing

final class IdentifierTests: XCTestCase, HasAllTests {

    struct AnIdentifier: DomainIdentifier {
        let rawValue: UUID
        init(rawValue: UUID) {
            self.rawValue = rawValue
        }
    }

    static var __allTests = [
        ("testCreation", testCreation),
        ("testAllTests", testAllTests)
    ]

    func testCreation() throws {
        // create arbitrary identifiers
        let identifier1 = AnIdentifier()
        let identifier2 = AnIdentifier()
        let uuid = UUID()
        // create identifier from given uuid
        let identifier3 = AnIdentifier(uuid: uuid)
        XCTAssertEqual(String(identifier3), uuid.base62String)
        // create identifier from given base62 encoded uuid
        let identifier4 = AnIdentifier(uuid.base62String)
        // identifier created from the same uuid must match
        XCTAssertEqual(identifier3, identifier4)
        // arbitrary identifiers must not match
        XCTAssertNotEqual(identifier1, identifier2)
        XCTAssertNotEqual(identifier1, identifier3)
        XCTAssertNotEqual(identifier1, identifier4)
        XCTAssertNotEqual(identifier2, identifier3)
        XCTAssertNotEqual(identifier2, identifier4)
    }

    func testAllTests() throws {
        assertAllTests()
    }

}
