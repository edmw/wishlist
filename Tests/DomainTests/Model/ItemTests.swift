@testable import Domain
import Foundation
import NIO

import XCTest
import Testing

final class ItemTests: XCTestCase, DomainTestCase, HasAllTests {

    static var __allTests = [
        ("testCreationFromValues", testCreationFromValues),
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

    func testCreationFromValues() throws {
        let url = Lorem.randomURL()
        let imageURL = Lorem.randomURL()
        let values = ItemValues(
            title: "aTitle",
            text: "aText",
            preference: "highest",
            url: url.absoluteString,
            imageURL: imageURL.absoluteString,
            createdAt: nil,
            modifiedAt: nil
        )
        let item = try Item(for: aList, from: values)
        XCTAssertEqual(item.title, "aTitle")
        XCTAssertEqual(item.text, "aText")
        XCTAssertEqual(item.preference, Item.Preference.highest)
        XCTAssertEqual(item.url, url)
        XCTAssertEqual(item.imageURL, imageURL)
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
