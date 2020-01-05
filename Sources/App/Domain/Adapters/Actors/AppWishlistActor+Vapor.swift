import Domain

import Vapor

// MARK: DomainWishlistActor

/// Adapter for the domain layers `WishlistActor` to be used with Vapor.
///
/// This adds the functionality needed that this actor can be injected by Vapor‘s dependency
/// injection framework.
extension DomainWishlistActor: ServiceType {

    // MARK: Service

    public static let serviceSupports: [Any.Type] = [WishlistActor.self]

    public static func makeService(for container: Container) throws -> Self {
        return .init(
            try container.make(ListRepository.self),
            try container.make(ItemRepository.self),
            try container.make(ReservationRepository.self),
            try container.make(FavoriteRepository.self),
            try container.make(UserRepository.self),
            VaporMessageLoggingProvider(with: container.requireLogger().application),
            VaporEventRecordingProvider(with: container.requireLogger().business)
        )
    }

}
