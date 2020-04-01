// sourcery:inline:DomainUserItemsActor.AutoActorService

// MARK: DO NOT EDIT

import Domain

import Vapor

// MARK: DomainUserItemsActor

/// Adapter for the domain layers `DomainUserItemsActor` to be used with Vapor.
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
            reservationRepository: container.make(),
            logging: container.make(),
            recording: container.make()
        )
    }

}
// sourcery:end
