// sourcery:inline:DomainWishlistActor.AutoActorService

// MARK: DO NOT EDIT

import Domain

import Vapor

// MARK: DomainWishlistActor

/// Adapter for the domain layers `DomainWishlistActor` to be used with Vapor.
///
/// This adds the functionality needed that this actor can be injected by Vapor‘s dependency
/// injection framework.
extension DomainWishlistActor: ServiceType {

    // MARK: Service

    public static let serviceSupports: [Any.Type] = [WishlistActor.self]

    public static func makeService(for container: Container) throws -> Self {
        return try .init(
            listRepository: container.make(),
            itemRepository: container.make(),
            reservationRepository: container.make(),
            favoriteRepository: container.make(),
            userRepository: container.make(),
            logging: container.make(),
            recording: container.make()
        )
    }

}
// sourcery:end
