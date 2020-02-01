// sourcery:inline:DomainUserFavoritesActor.AutoActorService

// MARK: DO NOT EDIT

import Domain

import Vapor

// MARK: DomainUserFavoritesActor

/// Adapter for the domain layers `DomainUserFavoritesActor` to be used with Vapor.
///
/// This adds the functionality needed that this actor can be injected by Vapor‘s dependency
/// injection framework.
extension DomainUserFavoritesActor: ServiceType {

    // MARK: Service

    public static let serviceSupports: [Any.Type] = [UserFavoritesActor.self]

    public static func makeService(for container: Container) throws -> Self {
        return try .init(
            favoriteRepository: container.make(),
            listRepository: container.make(),
            itemRepository: container.make(),
            userRepository: container.make(),
            logging: container.make(),
            recording: container.make()
        )
    }

}
// sourcery:end
