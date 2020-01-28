// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Domain

import Vapor

// MARK: DomainUserFavoritesActor

/// Adapter for the domain layers `DomainUserFavoritesActor` to be used with Vapor.
///
/// This adds the functionality needed that this repository can be injected by Vapor‘s dependency
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
