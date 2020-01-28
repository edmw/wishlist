// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Domain

import Vapor

// MARK: DomainUserInvitationsActor

/// Adapter for the domain layers `DomainUserInvitationsActor` to be used with Vapor.
///
/// This adds the functionality needed that this repository can be injected by Vapor‘s dependency
/// injection framework.
extension DomainUserInvitationsActor: ServiceType {

    // MARK: Service

    public static let serviceSupports: [Any.Type] = [UserInvitationsActor.self]

    public static func makeService(for container: Container) throws -> Self {
        return try .init(
            invitationRepository: container.make(),
            userRepository: container.make(),
            logging: container.make(),
            recording: container.make()
        )
    }

}
