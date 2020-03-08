@testable import Domain
import Foundation
import NIO

import XCTest
import Testing

final class InvitationTests: XCTestCase, DomainTestCase, HasAllTests {

    static var __allTests = [
        ("testCreationWithUser", testCreationWithUser),
        ("testCreationWithInvalidUser", testCreationWithInvalidUser),
        ("testAllTests", testAllTests)
    ]

    typealias EntityType = Invitation

    var eventLoop: EventLoop!
    var invitationRepository: InvitationRepository!
    var userRepository: UserRepository!

    override func setUp() {
        super.setUp()
        eventLoop = EmbeddedEventLoop()
        userRepository = TestingUserRepository(worker: eventLoop)
        invitationRepository = TestingInvitationRepository(
            worker: eventLoop,
            userRepository: userRepository
        )
    }

    func testCreationWithUser() throws {
        let user = try userRepository.save(user: User.randomUser()).wait()
        XCTAssertNotNil(user.id)
        let invitation = try Invitation(email: "email@host.invalid", user: user)
        let owner = try invitationRepository.owner(of: invitation).wait()
        XCTAssertEqual(user, owner)
    }

    func testCreationWithInvalidUser() throws {
        let user = User.randomUser()
        XCTAssertNil(user.id)
        assert(
            try Invitation(email: "email@host.invalid", user: user),
            throws: EntityError<User>.requiredIDMissing
        )
    }

    func testAllTests() throws {
        assertAllTests()
    }

}
