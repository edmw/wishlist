@testable import Domain
import Foundation
import NIO

import XCTest

/// Testing the most simple actor. The announcement actor just takes the id of an potential
/// user and returns a user representation then.
final class AnnouncementsActorTests : XCTestCase, HasAllTests {

    static var __allTests = [
        ("testPresentPubliclyWithUser", testPresentPubliclyWithUser),
        ("testPresentPubliclyWithoutUser", testPresentPubliclyWithoutUser),
        ("testPresentPubliclyWithInvalidUser", testPresentPubliclyWithInvalidUser),
        ("testAllTests", testAllTests)
    ]

    var eventLoop: EventLoop!
    var userRepository: UserRepository!

    var actor: AnnouncementsActor!

    override func setUp() {
        super.setUp()
        eventLoop = EmbeddedEventLoop()
        userRepository = TestingUserRepository(worker: eventLoop)
        actor = DomainAnnouncementsActor(userRepository)
    }

    /// Testing `PresentPublicly` action with an user id of an existing user.
    /// Expects an user representation which matches the representation of the
    /// corresponding user.
    func testPresentPubliclyWithUser() throws {
        let user = try! userRepository.save(user: UserSupport.randomUser()).wait()
        XCTAssertNotNil(user.userID)
        let result = try! actor.presentPublicly(
            .specification(userBy: user.userID),
            .boundaries(worker: eventLoop)
        ).wait()
        XCTAssertNotNil(result.user)
        XCTAssertEqual(result.user, UserRepresentation(user))
    }

    /// Testing `PresentPublicly` action with no user id.
    /// Expects a nil result.
    func testPresentPubliclyWithoutUser() throws {
        let result = try! actor.presentPublicly(
            .specification(userBy: nil),
            .boundaries(worker: eventLoop)
        ).wait()
        XCTAssertNil(result.user)
    }

    /// Testing `PresentPublicly` action with a non-existing user id.
    /// Expects the action to throw.
    func testPresentPubliclyWithInvalidUser() throws {
        assert(
            try actor.presentPublicly(
                    .specification(userBy: UserID()),
                    .boundaries(worker: eventLoop)
                ).wait(),
            throws: AnnouncementsActorError.invalidUser
        )
    }

    func testAllTests() throws {
        assertAllTests()
    }

}
