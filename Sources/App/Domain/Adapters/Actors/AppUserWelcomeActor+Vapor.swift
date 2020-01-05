import Domain

import Vapor

// MARK: DomainUserWelcomeActor

/// Adapter for the domain layers `UserWelcomeActor` to be used with Vapor.
///
/// This adds the functionality needed that this actor can be injected by Vapor‘s dependency
/// injection framework.
extension DomainUserWelcomeActor: ServiceType {

    // MARK: Service

    public static let serviceSupports: [Any.Type] = [UserWelcomeActor.self]

    public static func makeService(for container: Container) throws -> Self {
        return .init(
            try container.make(ListRepository.self),
            try container.make(FavoriteRepository.self),
            try container.make(ItemRepository.self),
            try container.make(UserRepository.self)
        )
    }

}
