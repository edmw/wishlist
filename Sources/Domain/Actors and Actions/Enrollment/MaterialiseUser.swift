// swiftlint:disable function_body_length closure_body_length

import Library

import Foundation
import NIO

// MARK: MaterialiseUser

public struct MaterialiseUser: Action {

    // MARK: Boundaries

    public struct Boundaries: AutoActionBoundaries {
        public let worker: EventLoop
    }

    // MARK: Specification

    public struct Options: OptionSet, Codable {
        public let rawValue: Int16

        public static let createUsers = Self(rawValue: 1 << 0)
        public static let requireInvitationToCreateUsers = Self(rawValue: 1 << 1)

        public init(rawValue: Int16) {
            self.rawValue = rawValue
        }
    }

    public struct Specification: AutoActionSpecification {
        public let options: MaterialiseUser.Options
        public let userIdentity: UserIdentity
        public let userIdentityProvider: UserIdentityProvider
        public let userValues: PartialValues<UserValues>
        public let invitationCode: InvitationCode?
        public let guestIdentification: Identification?
    }

    // MARK: Result

    public struct Result: ActionResult {
        public let userID: UserID
        public let user: UserRepresentation
        public let identification: Identification
        internal init(_ user: User) {
            guard let userid = user.userID else {
                fatalError("RealizeUser: no id for user")
            }
            self.userID = userid
            self.user = user.representation
            self.identification = user.identification
        }
    }

}

// MARK: - Actor

extension DomainEnrollmentActor {

    // MARK: materialiseUser

    /// Materialisation of a user is a rather complex process:
    /// After obtaining an authentication from an external third party login service, ...
    ///
    /// 1. We look up the user using the given user identity in our user repository.
    ///   a. If we are not able to find a user, authentication will continue if options allow to
    ///      create new users. We assume this is a first time materialisation, create a new user
    ///      entry in our repository and store the user’s values.
    ///   b. If we are not able to find a user and options allow to create new users with an
    ///      invitation only, we will check a possible invitation for validity and continue if
    ///      successful. We assume this is a first time materialisation, create a new user entry
    ///      in our repository and store the user’s values.
    ///   b. If we find the user in our repository, authentication will continue and we update the
    ///      user’s values. This allows the caller to provide updated values with every
    ///      materialisation. Of course, this is not possible for user editable values like
    ///      the user‘s nickname.
    ///
    /// 2. Next, we identify the user
    ///    (every user has an unique identification number attached, see Identification
    ///    for an explanation on why and how).
    ///   a. If there is an guest identification number provided we will use this number to
    ///      transfer the associated reservations to the user if they are not attached to another
    ///      user. This handles the case that a user makes reservations, anonymously and decides
    ///      later to materialise.
    public func materialiseUser(
        _ specification: MaterialiseUser.Specification,
        _ boundaries: MaterialiseUser.Boundaries
    ) throws -> EventLoopFuture<MaterialiseUser.Result> {
        let options = specification.options
        let userIdentity = specification.userIdentity
        let userIdentityProvider = specification.userIdentityProvider
        let userValues = specification.userValues
        let invitationCode = specification.invitationCode
        let guestIdentification = specification.guestIdentification

        // SEARCH USER BY IDENTITY
        return self.userRepository
            .find(identity: userIdentity, of: userIdentityProvider)

            // SEARCH INVITATION BY CODE
            .flatMap { user -> EventLoopFuture<(User?, Invitation?)> in
                // there may be a user (by identity)
                // now look up a potential invitation
                guard let invitationCode = invitationCode else {
                    // no invitation code given, proceed without invitation
                    return boundaries.worker.makeSucceededFuture((user, nil))
                }
                // search invitation by code and ensure the invitation is still open
                // proceed without invitation if none is found
                return self.invitationRepository
                    .find(by: invitationCode, status: .open)
                    .map { invitation in return (user, invitation) }
            }

            // MARK: create or update
            // ... new user or existing user
            .flatMap { arguments -> EventLoopFuture<(User, Invitation?)> in
                let (user, invitation) = arguments
                // there may by a user and may be an invitation
                if let user = user {
                    // existing user
                    return try self.userService
                        .updateUser(user, with: userValues)
                        .map { user in (user, invitation) }
                }
                else {
                    // creating user
                    guard options.contains(.createUsers) else {
                        let userEmail = userValues[\.email]
                        self.logging.message(
                            .userCreationNotAllowed(userEmail)
                        )
                        throw EnrollmentActorError.userCreationNotAllowed
                    }
                    guard !options.contains(.requireInvitationToCreateUsers)
                            || invitation != nil
                    else {
                        let userEmail = userValues[\.email]
                        self.logging.message(
                            .invitationForUserCreationNotProvided(userEmail, invitationCode)
                        )
                        throw EnrollmentActorError.invitationForUserCreationNotProvided
                    }
                    return try self.userService
                        .createUser(
                            from: userValues,
                            for: userIdentity,
                            of: userIdentityProvider
                        )
                        .map { user in (user, invitation) }
                }
            }

            // MARK: accept invitation
            // ... for user
            .flatMap { arguments -> EventLoopFuture<User> in
                let (user, invitation) = arguments
                // there must by a user and may be an invitation
                if let invitation = invitation {
                    // accept invitation for user
                    return try self.invitationService
                        .acceptInvitation(invitation, for: user)
                        .transform(to: user)
                }
                else {
                    return boundaries.worker.makeSucceededFuture(user)
                }
            }

            // MARK: transfer reservations
            // ... to user
            .flatMap { arguments -> EventLoopFuture<User> in
                let user = arguments
                // there must by a user
                if let guestIdentification = guestIdentification {
                    // transfer reservations to user
                    return try self.reservationService
                        .transferReservations(
                            from: guestIdentification,
                            to: user
                        )
                        .transform(to: user)
                }
                else {
                    return boundaries.worker.makeSucceededFuture(user)
                }
            }

            // MARK: save
            // ... user and return
            .flatMap { user in
                if let firstLogin = user.firstLogin, firstLogin == user.lastLogin {
                    // new user, emit business event
                    self.recording.event("\(user) created at \(firstLogin)")
                }

                return self.userRepository
                    .save(user: user)
                    .recordEvent("materialised", using: self.recording)
                    .logMessage(.materialiseUser, using: self.logging)
                    .map { user in .init(user) }
            }
    }

}

// MARK: Logging

extension LoggingMessage {

    fileprivate static func userCreationNotAllowed(
        _ email: EmailSpecification?
    ) -> LoggingMessage {
        let message = "Authentication for user denied: User Creation Not Allowed."
        return Self(
            warn: "User Creation Not Allowed",
            subject: email ?? "",
            attributes: [ "message": message ]
        )
    }

    fileprivate static func invitationForUserCreationNotProvided(
        _ email: EmailSpecification?,
        _ invitationCode: InvitationCode?
    ) -> LoggingMessage {
        let message = "Authentication for user denied: Invitation for User Creation not provided."
        return Self(
            warn: "Invitation for User Creation not provided",
            subject: email ?? "",
            attributes: [ "message": message, "InvitationCode": invitationCode as Any ]
        )
    }

}

// MARK: Logging

extension LoggingMessageRoot {

    fileprivate static var materialiseUser: LoggingMessageRoot<User> {
        return .init({ user in
            LoggingMessage(label: "Materialise User", subject: user)
        })
    }

}
