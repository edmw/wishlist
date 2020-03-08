@testable import Domain
import Foundation
import NIO

import XCTest
import Testing

/// Testing the most simple actor. The announcement actor just takes the id of an potential
/// user and returns a user representation then.
final class AnnouncementsActorTests : ActorTestCase, DomainTestCase, HasAllTests {

    static var __allTests = [
        ("testPresentPubliclyWithUser", testPresentPubliclyWithUser),
        ("testPresentPubliclyWithoutUser", testPresentPubliclyWithoutUser),
        ("testPresentPubliclyWithInvalidUser", testPresentPubliclyWithInvalidUser),
        ("testAllTests", testAllTests)
    ]

    var actor: AnnouncementsActor!

    override func setUp() {
        super.setUp()

        actor = DomainAnnouncementsActor(userRepository: userRepository)
    }

    /// Testing `PresentPublicly` action with an user id of an existing user.
    /// Expects a user representation which matches the representation of the
    /// corresponding user.
    func testPresentPubliclyWithUser() throws {
        let user = try! userRepository.save(user: User.randomUser()).wait()
        XCTAssertNotNil(user.id)
        let result = try! actor.presentPublicly(
            .specification(userBy: user.id),
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
