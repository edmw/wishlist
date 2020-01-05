import Domain

import Vapor

// MARK: DomainUserNotificationsActor

/// Adapter for the domain layers `UserNotificationsActor` to be used with Vapor.
///
/// This adds the functionality needed that this actor can be injected by Vapor‘s dependency
/// injection framework.
extension DomainUserNotificationsActor: ServiceType {

    // MARK: Service

    public static let serviceSupports: [Any.Type] = [UserNotificationsActor.self]

    public static func makeService(for container: Container) throws -> Self {
        return .init(
            try container.make(UserRepository.self),
            VaporMessageLoggingProvider(with: container.requireLogger().application),
            VaporEventRecordingProvider(with: container.requireLogger().business)
        )
    }

}
