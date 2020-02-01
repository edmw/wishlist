// sourcery:inline:DomainUserNotificationsActor.AutoActorService

// MARK: DO NOT EDIT

import Domain

import Vapor

// MARK: DomainUserNotificationsActor

/// Adapter for the domain layers `DomainUserNotificationsActor` to be used with Vapor.
///
/// This adds the functionality needed that this actor can be injected by Vapor‘s dependency
/// injection framework.
extension DomainUserNotificationsActor: ServiceType {

    // MARK: Service

    public static let serviceSupports: [Any.Type] = [UserNotificationsActor.self]

    public static func makeService(for container: Container) throws -> Self {
        return try .init(
            userRepository: container.make(),
            logging: container.make(),
            recording: container.make()
        )
    }

}
// sourcery:end
