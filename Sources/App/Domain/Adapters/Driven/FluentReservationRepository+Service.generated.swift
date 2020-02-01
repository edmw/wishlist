// sourcery:inline:FluentReservationRepository.AutoRepositoryService

// MARK: DO NOT EDIT

import Domain

import Vapor

// MARK: FluentReservationRepository

/// Adapter for the domain layers `FluentReservationRepository` to be used with Vapor.
///
/// This adds the functionality needed that this repository can be injected by Vapor‘s dependency
/// injection framework.
extension FluentReservationRepository: ServiceType {

    // MARK: Service

    public static let serviceSupports: [Any.Type] = [ReservationRepository.self]

    public static func makeService(for worker: Container) throws -> Self {
        return .init(try worker.connectionPool(to: .mysql))
    }

}
// sourcery:end
