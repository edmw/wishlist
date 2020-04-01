@testable import Domain
import Foundation
import NIO

import XCTest
import Testing

final class EnrollmentActorTests : ActorTestCase, DomainTestCase, HasAllTests {

    static var __allTests = [
        ("testMaterialiseUser", testMaterialiseUser),
        ("testMaterialiseUserWithInvitation", testMaterialiseUserWithInvitation),
        ("testMaterialiseUserWithRequiredInvitation", testMaterialiseUserWithRequiredInvitation),
        ("testMaterialiseUserWithNoInvitation", testMaterialiseUserWithNoInvitation),
        ("testMaterialiseUserWithInvalidInvitation", testMaterialiseUserWithInvalidInvitation),
        ("testMaterialiseUserWithAlreadyAcceptedInvitation", testMaterialiseUserWithAlreadyAcceptedInvitation),
        ("testAllTests", testAllTests)
    ]

    var useridentity: UserIdentity!
    var useridentityprovider: UserIdentityProvider!
    var uservalues: UserValues!
    var partialuservalues: PartialValues<UserValues>!

    var aUser: User!
    var anInvitation: Invitation!

    override func setUp() {
        super.setUp()

        useridentity = UserIdentity(string: "itsme")
        useridentityprovider = UserIdentityProvider(string: "itsus")
        uservalues = User.randomUserValues()
        partialuservalues = PartialValues<UserValues>(wrapped: uservalues)

        aUser = try! userRepository.save(user: User.randomUser()).wait()
        anInvitation = try! invitationRepository
            .save(invitation: Invitation(
                    email: EmailSpecification(string: "a@b.c"),
                    user: aUser
                )
            ).wait()
        XCTAssertEqual(anInvitation.userID, aUser.id)
    }

    func assertCreatedUser(_ user: UserRepresentation) {
        let theUser = try! userRepository
            .find(identity: useridentity, of: useridentityprovider)
            .wait()
        XCTAssertNotNil(theUser)
        XCTAssertEqual(user, UserRepresentation(theUser!))
    }

    // MARK: Test

    func testMaterialiseUser() throws {
        let count = try! userRepository.count().wait()
        let result = try! enrollmentActor.materialiseUser(
                .specification(
                    options: [.createUsers],
                    userIdentity: useridentity,
                    userIdentityProvider: useridentityprovider,
                    userValues: partialuservalues,
                    invitationCode: nil,
                    guestIdentification: nil
                ),
                .boundaries(worker: eventLoop)
            ).wait()
        XCTAssertEqual(result.user.email, String(uservalues.email))
        XCTAssertEqual(result.user.fullName, String(uservalues.fullName))
        let theCount = try! userRepository.count().wait()
        XCTAssertEqual(theCount, count + 1)
        assertCreatedUser(result.user)
    }

    // MARK: with Invitation

    func assertUpdatedInvitation(_ anInvitation: Invitation) {
        let theUser = try! userRepository
            .find(identity: useridentity, of: useridentityprovider)
            .wait()
        let theInvitation = try! invitationRepository.find(by: anInvitation.id!).wait()
        XCTAssertNotNil(theInvitation)
        XCTAssertEqual(theInvitation!.id, anInvitation.id)
        // invitation must be accepted
        XCTAssertEqual(theInvitation!.status, Invitation.Status.accepted)
        // invitation must be accepted by the created user
        XCTAssertEqual(theInvitation!.inviteeID, theUser!.id)
    }

    func testMaterialiseUserWithInvitation() throws {
        let result = try! enrollmentActor.materialiseUser(
                .specification(
                    options: [.createUsers],
                    userIdentity: useridentity,
                    userIdentityProvider: useridentityprovider,
                    userValues: partialuservalues,
                    invitationCode: anInvitation.code,
                    guestIdentification: nil
                ),
                .boundaries(worker: eventLoop)
            ).wait()
        assertCreatedUser(result.user)
        assertUpdatedInvitation(anInvitation)
    }

    func testMaterialiseUserWithRequiredInvitation() throws {
        let result = try! enrollmentActor.materialiseUser(
                .specification(
                    options: [.createUsers, .requireInvitationToCreateUsers],
                    userIdentity: useridentity,
                    userIdentityProvider: useridentityprovider,
                    userValues: partialuservalues,
                    invitationCode: anInvitation.code,
                    guestIdentification: nil
                ),
                .boundaries(worker: eventLoop)
            ).wait()
        assertCreatedUser(result.user)
        assertUpdatedInvitation(anInvitation)
    }

    func testMaterialiseUserWithNoInvitation() throws {
        assert(
            try enrollmentActor.materialiseUser(
                    .specification(
                        options: [.createUsers, .requireInvitationToCreateUsers],
                        userIdentity: useridentity,
                        userIdentityProvider: useridentityprovider,
                        userValues: partialuservalues,
                        invitationCode: nil,
                        guestIdentification: nil
                    ),
                    .boundaries(worker: eventLoop)
                ).wait(),
            throws: EnrollmentActorError.invitationForUserCreationNotProvided
        )
    }

    func testMaterialiseUserWithInvalidInvitation() throws {
        assert(
            try enrollmentActor.materialiseUser(
                    .specification(
                        options: [.createUsers, .requireInvitationToCreateUsers],
                        userIdentity: useridentity,
                        userIdentityProvider: useridentityprovider,
                        userValues: partialuservalues,
                        invitationCode: InvitationCode(),
                        guestIdentification: nil
                    ),
                    .boundaries(worker: eventLoop)
                ).wait(),
            throws: EnrollmentActorError.invitationForUserCreationNotProvided
        )
    }

    func testMaterialiseUserWithAlreadyAcceptedInvitation() throws {
        anInvitation = try! invitationService.acceptInvitation(anInvitation, for: aUser).wait()
        assert(
            try enrollmentActor.materialiseUser(
                    .specification(
                        options: [.createUsers, .requireInvitationToCreateUsers],
                        userIdentity: useridentity,
                        userIdentityProvider: useridentityprovider,
                        userValues: partialuservalues,
                        invitationCode: anInvitation.code,
                        guestIdentification: nil
                    ),
                    .boundaries(worker: eventLoop)
                ).wait(),
            throws: EnrollmentActorError.invitationForUserCreationNotProvided
        )
    }

    // MARK: with Reservations

    func testAllTests() throws {
        assertAllTests()
    }

}
