@testable import Domain
import Foundation
import NIO

import XCTest
import Testing

final class ItemTests: XCTestCase, HasAllTests {

    static var __allTests = [
        ("testImaginable", testImaginable),
        ("testAllTests", testAllTests)
    ]

    var aUser: User!
    var aList: List!

    override func setUp() {
        super.setUp()

        aUser = User.randomUser().withFakeID()
        aList = List.randomList(for: aUser).withFakeID()
    }

    func testImaginable() throws {
        let item = Item.randomItem(for: aList)
        item.id = ItemID("46QfEaPfUXMcvlP4dPgQJ6")
        XCTAssertEqual(item.imageableEntityKey, "46QfEaPfUXMcvlP4dPgQJ6")
        XCTAssertEqual(item.imageableEntityGroupKeys, ["46Q", "fEa"])
        let imageableSize = item.imageableSize
        XCTAssertEqual(imageableSize.width, 512)
        XCTAssertEqual(imageableSize.height, 512)
    }

    func testAllTests() throws {
        assertAllTests()
    }

}
