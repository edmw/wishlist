// sourcery:inline:DomainEnrollmentActor.AutoActorService

// MARK: DO NOT EDIT

import Domain

import Vapor

// MARK: DomainEnrollmentActor

/// Adapter for the domain layers `DomainEnrollmentActor` to be used with Vapor.
///
/// This adds the functionality needed that this actor can be injected by Vapor‘s dependency
/// injection framework.
extension DomainEnrollmentActor: ServiceType {

    // MARK: Service

    public static let serviceSupports: [Any.Type] = [EnrollmentActor.self]

    public static func makeService(for container: Container) throws -> Self {
        return try .init(
            userRepository: container.make(),
            invitationRepository: container.make(),
            reservationRepository: container.make(),
            logging: container.make(),
            recording: container.make()
        )
    }

}
// sourcery:end
