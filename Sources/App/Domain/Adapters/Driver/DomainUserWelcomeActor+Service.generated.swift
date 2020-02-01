// sourcery:inline:DomainUserWelcomeActor.AutoActorService

// MARK: DO NOT EDIT

import Domain

import Vapor

// MARK: DomainUserWelcomeActor

/// Adapter for the domain layers `DomainUserWelcomeActor` to be used with Vapor.
///
/// This adds the functionality needed that this actor can be injected by Vapor‘s dependency
/// injection framework.
extension DomainUserWelcomeActor: ServiceType {

    // MARK: Service

    public static let serviceSupports: [Any.Type] = [UserWelcomeActor.self]

    public static func makeService(for container: Container) throws -> Self {
        return try .init(
            listRepository: container.make(),
            favoriteRepository: container.make(),
            itemRepository: container.make(),
            userRepository: container.make()
        )
    }

}
// sourcery:end
