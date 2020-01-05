import Domain

import Vapor

// MARK: DomainUserSettingsActor

/// Adapter for the domain layers `UserSettingsActor` to be used with Vapor.
///
/// This adds the functionality needed that this actor can be injected by Vapor‘s dependency
/// injection framework.
extension DomainUserSettingsActor: ServiceType {

    // MARK: Service

    public static let serviceSupports: [Any.Type] = [UserSettingsActor.self]

    public static func makeService(for container: Container) throws -> Self {
        return .init(
            try container.make(UserRepository.self),
            VaporMessageLoggingProvider(with: container.requireLogger().application),
            VaporEventRecordingProvider(with: container.requireLogger().business)
        )
    }

}
