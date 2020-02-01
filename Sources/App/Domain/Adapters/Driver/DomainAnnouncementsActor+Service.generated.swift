// sourcery:inline:DomainAnnouncementsActor.AutoActorService

// MARK: DO NOT EDIT

import Domain

import Vapor

// MARK: DomainAnnouncementsActor

/// Adapter for the domain layers `DomainAnnouncementsActor` to be used with Vapor.
///
/// This adds the functionality needed that this actor can be injected by Vapor‘s dependency
/// injection framework.
extension DomainAnnouncementsActor: ServiceType {

    // MARK: Service

    public static let serviceSupports: [Any.Type] = [AnnouncementsActor.self]

    public static func makeService(for container: Container) throws -> Self {
        return try .init(
            userRepository: container.make()
        )
    }

}
// sourcery:end
