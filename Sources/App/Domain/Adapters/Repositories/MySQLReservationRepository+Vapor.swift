import Domain

import Vapor

// MARK: MySQLReservationRepository

/// Adapter for the domain layers `ReservationRepository` to be used with Vapor.
///
/// This adds the functionality needed that this repository can be injected by Vapor‘s dependency
/// injection framework.
extension MySQLReservationRepository: ServiceType {

    // MARK: Service

    static let serviceSupports: [Any.Type] = [ReservationRepository.self]

    static func makeService(for worker: Container) throws -> Self {
        return .init(try worker.connectionPool(to: .mysql))
    }

}
