import Domain

import Vapor

// MARK: DomainUserItemsActor

/// Adapter for the domain layers `UserItemsActor` to be used with Vapor.
///
/// This adds the functionality needed that this actor can be injected by Vapor‘s dependency
/// injection framework.
extension DomainUserItemsActor: ServiceType {

    // MARK: Service

    public static let serviceSupports: [Any.Type] = [UserItemsActor.self]

    public static func makeService(for container: Container) throws -> Self {
        return try .init(
            itemRepository: container.make(),
            listRepository: container.make(),
            userRepository: container.make(),
            logging: container.make(),
            recording: container.make()
        )
    }

}
