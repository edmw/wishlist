@testable import Domain
import Foundation
import NIO

import XCTest

final class EnrollmentActorTests : XCTestCase, HasAllTests {

    static var __allTests = [
        ("testMaterialiseUser", testMaterialiseUser),
        ("testMaterialiseUserWithInvitation", testMaterialiseUserWithInvitation),
        ("testMaterialiseUserWithRequiredInvitation", testMaterialiseUserWithRequiredInvitation),
        ("testMaterialiseUserWithNoInvitation", testMaterialiseUserWithNoInvitation),
        ("testMaterialiseUserWithInvalidInvitation", testMaterialiseUserWithInvalidInvitation),
        ("testMaterialiseUserWithAlreadyAcceptedInvitation", testMaterialiseUserWithAlreadyAcceptedInvitation),
        ("testAllTests", testAllTests)
    ]

    var eventLoop: EventLoop!
    var userRepository: UserRepository!
    var invitationRepository: InvitationRepository!
    var reservationRepository: ReservationRepository!
    var invitationService: InvitationService!
    var logging: TestingLoggingProvider!
    var recording: TestingRecordingProvider!

    var useridentity: UserIdentity!
    var useridentityprovider: UserIdentityProvider!
    var uservalues: UserValues!
    var partialuservalues: PartialValues<UserValues>!

    var aUser: User!
    var anInvitation: Invitation!

    var actor: EnrollmentActor!

    override func setUp() {
        super.setUp()

        eventLoop = EmbeddedEventLoop()
        userRepository = TestingUserRepository(
            worker: eventLoop
        )
        invitationRepository = TestingInvitationRepository(
            worker: eventLoop,
            userRepository: userRepository
        )
        reservationRepository = TestingReservationRepository(
            worker: eventLoop
        )
        invitationService = InvitationService(invitationRepository)
        logging = TestingLoggingProvider()
        recording = TestingRecordingProvider()

        useridentity = UserIdentity(string: "itsme")
        useridentityprovider = UserIdentityProvider(string: "itsus")
        uservalues = UserSupport.randomUserValues()
        partialuservalues = PartialValues<UserValues>(wrapped: uservalues)

        aUser = try! userRepository.save(user: UserSupport.randomUser()).wait()
        anInvitation = try! invitationRepository
            .save(invitation: Invitation(
                    email: EmailSpecification(string: "a@b.c"),
                    user: aUser
                )
            ).wait()
        XCTAssertEqual(anInvitation.userID, aUser.id)

        actor = DomainEnrollmentActor(
            invitationRepository,
            reservationRepository,
            userRepository,
            logging,
            recording
        )
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
        let result = try! actor.materialiseUser(
                .specification(
                    userIdentity: useridentity,
                    userIdentityProvider: useridentityprovider,
                    userValues: partialuservalues
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
        let theInvitation = try! invitationRepository.find(by: anInvitation.invitationID!).wait()
        XCTAssertNotNil(theInvitation)
        XCTAssertEqual(theInvitation!.invitationID, anInvitation.invitationID)
        // invitation must be accepted
        XCTAssertEqual(theInvitation!.status, Invitation.Status.accepted)
        // invitation must be accepted by the created user
        XCTAssertEqual(theInvitation!.invitee, theUser!.id)
    }

    func testMaterialiseUserWithInvitation() throws {
        let result = try! actor.materialiseUser(
                .specification(
                    userIdentity: useridentity,
                    userIdentityProvider: useridentityprovider,
                    userValues: partialuservalues,
                    invitationCode: anInvitation.code
                ),
                .boundaries(worker: eventLoop)
            ).wait()
        assertCreatedUser(result.user)
        assertUpdatedInvitation(anInvitation)
    }

    func testMaterialiseUserWithRequiredInvitation() throws {
        let result = try! actor.materialiseUser(
                .specification(
                    options: [.createUsers, .requireInvitationToCreateUsers],
                    userIdentity: useridentity,
                    userIdentityProvider: useridentityprovider,
                    userValues: partialuservalues,
                    invitationCode: anInvitation.code
                ),
                .boundaries(worker: eventLoop)
            ).wait()
        assertCreatedUser(result.user)
        assertUpdatedInvitation(anInvitation)
    }

    func testMaterialiseUserWithNoInvitation() throws {
        assert(
            try actor.materialiseUser(
                    .specification(
                        options: [.createUsers, .requireInvitationToCreateUsers],
                        userIdentity: useridentity,
                        userIdentityProvider: useridentityprovider,
                        userValues: partialuservalues
                    ),
                    .boundaries(worker: eventLoop)
                ).wait(),
            throws: EnrollmentActorError.invitationForUserCreationNotProvided
        )
    }

    func testMaterialiseUserWithInvalidInvitation() throws {
        assert(
            try actor.materialiseUser(
                    .specification(
                        options: [.createUsers, .requireInvitationToCreateUsers],
                        userIdentity: useridentity,
                        userIdentityProvider: useridentityprovider,
                        userValues: partialuservalues,
                        invitationCode: InvitationCode()
                    ),
                    .boundaries(worker: eventLoop)
                ).wait(),
            throws: EnrollmentActorError.invitationForUserCreationNotProvided
        )
    }

    func testMaterialiseUserWithAlreadyAcceptedInvitation() throws {
        anInvitation = try! invitationService.acceptInvitation(anInvitation, for: aUser).wait()
        assert(
            try actor.materialiseUser(
                    .specification(
                        options: [.createUsers, .requireInvitationToCreateUsers],
                        userIdentity: useridentity,
                        userIdentityProvider: useridentityprovider,
                        userValues: partialuservalues,
                        invitationCode: anInvitation.code
                    ),
                    .boundaries(worker: eventLoop)
                ).wait(),
            throws: EnrollmentActorError.invitationForUserCreationNotProvided
        )
    }

    // MARK: with Reservations

    func testAllTests() {
        assertAllTests()
    }

}
