// sourcery:inline:DomainUserProfileActor.AutoActorService

// MARK: DO NOT EDIT

import Domain

import Vapor

// MARK: DomainUserProfileActor

/// Adapter for the domain layers `DomainUserProfileActor` to be used with Vapor.
///
/// This adds the functionality needed that this actor can be injected by Vapor‘s dependency
/// injection framework.
extension DomainUserProfileActor: ServiceType {

    // MARK: Service

    public static let serviceSupports: [Any.Type] = [UserProfileActor.self]

    public static func makeService(for container: Container) throws -> Self {
        return try .init(
            userRepository: container.make(),
            invitationRepository: container.make(),
            logging: container.make(),
            recording: container.make()
        )
    }

}
// sourcery:end
