import Domain

import Vapor

// MARK: DomainUserListsActor

/// Adapter for the domain layers `UserListsActor` to be used with Vapor.
///
/// This adds the functionality needed that this actor can be injected by Vapor‘s dependency
/// injection framework.
extension DomainUserListsActor: ServiceType {

    // MARK: Service

    public static let serviceSupports: [Any.Type] = [UserListsActor.self]

    public static func makeService(for container: Container) throws -> Self {
        return try .init(
            userItemsActor: container.make(),
            listRepository: container.make(),
            itemRepository: container.make(),
            userRepository: container.make(),
            logging: container.make(),
            recording: container.make()
        )
    }

}
