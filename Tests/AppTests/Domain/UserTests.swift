@testable import App
@testable import Domain
import Foundation
import NIO

import XCTest
import Testing

final class DomainModelUserTests: XCTestCase, HasEntityTestSupport, HasAllTests {

    static var __allTests = [
        ("testProperties", testProperties),
        ("testMapping", testMapping),
        ("testAllTests", testAllTests)
    ]

    typealias EntityType = User
    typealias ModelType = FluentUser

    func testProperties() throws {
        entityTestProperties()
    }

    func testMapping() throws {
        let model = FluentUser(
            uuid: UUID(),
            identification: Identification(),
            email: "abc@1234.ab",
            fullName: "abc def",
            firstName: "abc",
            lastName: "def",
            nickName: "a",
            language: "aa",
            picture: URL(string: "http://abc.ab"),
            confidant: false,
            settings: UserSettings(),
            firstLogin: Date(),
            lastLogin: Date(),
            identity: "abcdefghijk",
            identityProvider: "1234567890"
        )
        let entity = User(from: model)
        XCTAssertEqual(entity.model, model)
    }

    func testAllTests() throws {
        assertAllTests()
    }

}
