import Domain

import Vapor

// MARK: DomainUserReservationsActor

/// Adapter for the domain layers `UserReservationsActor` to be used with Vapor.
///
/// This adds the functionality needed that this actor can be injected by Vapor‘s dependency
/// injection framework.
extension DomainUserReservationsActor: ServiceType {

    // MARK: Service

    public static let serviceSupports: [Any.Type] = [UserReservationsActor.self]

    public static func makeService(for container: Container) throws -> Self {
        return .init(
            try container.make(ItemRepository.self),
            try container.make(ReservationRepository.self),
            VaporMessageLoggingProvider(with: container.requireLogger().application),
            VaporEventRecordingProvider(with: container.requireLogger().business)
        )
    }

}
