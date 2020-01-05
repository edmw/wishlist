import Domain

import Vapor

// MARK: DomainUserFavoritesActor

/// Adapter for the domain layers `UserFavoritesActor` to be used with Vapor.
///
/// This adds the functionality needed that this actor can be injected by Vapor‘s dependency
/// injection framework.
extension DomainUserFavoritesActor: ServiceType {

    // MARK: Service

    public static let serviceSupports: [Any.Type] = [UserFavoritesActor.self]

    public static func makeService(for container: Container) throws -> Self {
        return .init(
            try container.make(FavoriteRepository.self),
            try container.make(ListRepository.self),
            try container.make(ItemRepository.self),
            try container.make(UserRepository.self),
            VaporMessageLoggingProvider(with: container.requireLogger().application),
            VaporEventRecordingProvider(with: container.requireLogger().business)
        )
    }

}
