// swiftlint:disable function_body_length closure_body_length

import Vapor

/// Authenticating an user is a rather complex process:
/// After obtaining an authentication from an external third party login service, ...
///
/// 1. We look up the user using the given user info in our user repository.
///   a. If we are not able to find a user, authentication will continue if site access is open for
///      new users. We assume this is a first time login, create a new user entry in our
///      repository and store the user’s data.
///   b. If we are not able to find a user and site access is open for invited user, we will check
///      a possible invitation for validity and continue if successful. We assume this is a first
///      time login, create a new user entry in our repository and store the user’s data.
///   b. If we find the user in our repository, authentication will continue if site access is not
///      locked and we update the user’s data.
///
/// 2. Next, we identify the user
///    (every user has an unique identification number attached, see Identification
///    for an explanation on why and how).
///   a. If there is an existing identification number in the session or request we will get
///      this number and transfer the associated reservations to the user if they are not attached
///      to another user.
///
/// 3. Finally, after we found the user and made sure there is an identification number for that
/// user, we will authenticate the user into the session.
extension Request {

    func authenticate(
        using userInfo: AuthenticationUserInfo,
        state: AuthenticationState,
        access: SiteAccess
    ) throws
        -> EventLoopFuture<User>
    {
        // get identification from request or session
        let requestIdentification = try self.requireIdentification()

        let userRepository = try make(UserRepository.self)
        // future to check the existance of an user
        let checkUser = try userRepository.checkUser(using: userInfo)

        let invitationRepository = try make(InvitationRepository.self)
        // future to find an open invitation (if invitation code is given)
        let findInvitation: EventLoopFuture<Invitation?>
        if let invitationCode = state.invitationCode {
            findInvitation = invitationRepository.find(by: invitationCode)
        }
        else {
            findInvitation = future(nil)
        }

        // Step 1: the security
        // - check existance of user and find a possible invitation
        // - check access for the new or existing user with the possible invitation
        // - invalidate the possible invitation
        // returns the user (created or updated)
        return flatMap(checkUser, findInvitation) { userExists, invitation
            -> EventLoopFuture<User> in

            // check access for user (throws on access violation)
            switch access {
            case .all:
                // all users are permitted, continue
                break
            case .invited:
                // only existing or invited users are permitted
                if userExists {
                    break
                }
                guard let invitation = invitation else {
                    self.logger?.application.noInvitation(userInfo.email)
                    throw AuthenticationError.notExistingUserNorInvitedUser
                }
                guard invitation.status == .open else {
                    self.logger?.application.invalidInvitation(userInfo.email, invitation.code)
                    throw AuthenticationError.notExistingUserNorInvitedUser
                }
            case .existing:
                // only existing users are permitted
                guard userExists else {
                    self.logger?.application.existingUsers(userInfo.email)
                    throw AuthenticationError.notExistingUser
                }
            case .nobody:
                // nobody is permitted, site is locked
                self.logger?.application.siteLocked(userInfo.email)
                throw AuthenticationError.siteLocked
            }

            // Security: to avoid session fixation delete current session and create a new one
            try self.destroySession()

            // if access is permitted realize user and accept invitation
            return try userRepository.realizeUser(using: userInfo)
                .flatMap { user in
                    if let invitation = invitation {
                        return try invitationRepository
                            .accept(invitation, for: user)
                            .transform(to: user)
                    }
                    else {
                        return self.future(user)
                    }
                }
        }

        // Step 2: the business
        // - do business events
        // - handle reservations made anonymously
        // returns the user
        .flatMap { user -> EventLoopFuture<User> in
            if let firstLogin = user.firstLogin, firstLogin == user.lastLogin {
                // new user, emit business log event
                self.logger?.business.info("\(user) created at \(firstLogin)")
            }

            // lookup identification from request
            return userRepository
                .find(identification: requestIdentification)
                .flatMap { result in
                    let transferReservations: EventLoopFuture<Void>
                    if result == nil {
                        // identification from request is not attached to another user,
                        // transfer (maybe existing) reservations
                        transferReservations = try self.make(ReservationRepository.self)
                            .transfer(from: requestIdentification, to: user.identification)
                    }
                    else {
                        // identification from request is attached to another user,
                        // just ignore it (actually this should not happen)
                        transferReservations = self.future()
                    }
                    // save user with attached identification
                    return transferReservations.then { _ in
                        return userRepository.save(user: user)
                    }
                }
        }

        // Step 3: the login
        // - attach user to session
        // returns user
        .map { user in
            // attach user to session
            try self.authenticateSession(user)

            self.logger?.application.info("Sucessfully authenticated \(user)")

            return user
        }
    }

}

extension UserRepository {

    /// checks if a user for the specified user info exists
    func checkUser(using userInfo: AuthenticationUserInfo) throws
        -> EventLoopFuture<Bool>
    {
        try userInfo.validate()
        return find(subjectId: userInfo.subjectId).map { $0 != nil }
    }

    func realizeUser(using userInfo: AuthenticationUserInfo) throws
        -> EventLoopFuture<User>
    {
        try userInfo.validate()

        // lookup user in database and update if found, create if not
        let subjectId = userInfo.subjectId
        return find(subjectId: subjectId)
            .flatMap { result -> EventLoopFuture<User> in
                let user: User
                if let result = result {
                    // update existing user
                    user = result
                    user.update(userInfo)
                    user.lastLogin = Date()
                }
                else {
                    // create new user
                    user = User(userInfo)
                    user.firstLogin = Date()
                    user.lastLogin = user.firstLogin
                }
                return self.save(user: user)
            }
    }

}

extension InvitationRepository {

    func accept(_ invitation: Invitation, for user: User) throws
        -> EventLoopFuture<Invitation>
    {
        return try invitation.update(status: .accepted, in: self)
            .flatMap { invitation in
                invitation.invitee = try user.requireID()
                return self.save(invitation: invitation)
            }
    }

}

extension Logger {

    fileprivate func noInvitation(_ email: String) {
        self.warning(
            "Authentication for user with email \(email) denied: No invitation"
        )
    }

    fileprivate func invalidInvitation(_ email: String, _ code: InvitationCode) {
        self.warning(
            "Authentication for user with email \(email) denied:" +
                " Invalid invitation with code \(code)"
        )
    }

    fileprivate func existingUsers(_ email: String) {
        self.warning(
            "Authentication for user with email \(email) denied:" +
                " New user not permitted for access level ´existing´"
        )
    }

    fileprivate func siteLocked(_ email: String) {
        self.warning(
            "Authentication for user with email \(email) denied: Site is locked"
        )
    }

}
