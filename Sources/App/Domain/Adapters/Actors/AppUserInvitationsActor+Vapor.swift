import Domain

import Vapor

// MARK: DomainUserInvitationsActor

/// Adapter for the domain layers `UserInvitationsActor` to be used with Vapor.
///
/// This adds the functionality needed that this actor can be injected by Vapor‘s dependency
/// injection framework.
extension DomainUserInvitationsActor: ServiceType {

    // MARK: Service

    public static let serviceSupports: [Any.Type] = [UserInvitationsActor.self]

    public static func makeService(for container: Container) throws -> Self {
        return .init(
            try container.make(InvitationRepository.self),
            try container.make(UserRepository.self),
            VaporMessageLoggingProvider(with: container.requireLogger().application),
            VaporEventRecordingProvider(with: container.requireLogger().business)
        )
    }

}
