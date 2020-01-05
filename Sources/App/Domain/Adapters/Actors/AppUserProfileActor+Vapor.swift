import Domain

import Vapor

// MARK: DomainUserProfileActor

/// Adapter for the domain layers `UserProfileActor` to be used with Vapor.
///
/// This adds the functionality needed that this actor can be injected by Vapor‘s dependency
/// injection framework.
extension DomainUserProfileActor: ServiceType {

    // MARK: Service

    public static let serviceSupports: [Any.Type] = [UserProfileActor.self]

    public static func makeService(for container: Container) throws -> Self {
        return .init(
            try container.make(UserRepository.self),
            try container.make(InvitationRepository.self),
            VaporMessageLoggingProvider(with: container.requireLogger().application),
            VaporEventRecordingProvider(with: container.requireLogger().business)
        )
    }

}
