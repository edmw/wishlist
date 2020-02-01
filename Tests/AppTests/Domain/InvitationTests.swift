@testable import App
@testable import Domain
import Foundation
import NIO

import XCTest

final class InvitationTests: XCTestCase, HasEntityTestSupport, HasAllTests {

    static var __allTests = [
        ("testProperties", testProperties),
        ("testMapping", testMapping),
        ("testAllTests", testAllTests)
    ]

    typealias EntityType = Invitation
    typealias ModelType = FluentInvitation

    func testProperties() throws {
        entityTestProperties()
    }

    func testMapping() {
        let model = FluentInvitation(
            id: UUID(),
            code: InvitationCode(),
            status: .accepted,
            email: EmailSpecification("123@abc.de"),
            sentAt: Date(),
            createdAt: Date(),
            userID: UUID(),
            invitee: UUID()
        )
        let entity = Invitation(from: model)
        XCTAssertEqual(entity.model, model)
    }

    func testAllTests() throws {
        assertAllTests()
    }

}
