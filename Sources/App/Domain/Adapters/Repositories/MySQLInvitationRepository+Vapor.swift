import Domain

import Vapor

// MARK: MySQLInvitationRepository

/// Adapter for the domain layers `InvitationRepository` to be used with Vapor.
///
/// This adds the functionality needed that this repository can be injected by Vapor‘s dependency
/// injection framework.
extension MySQLInvitationRepository: ServiceType {

    // MARK: Service

    static let serviceSupports: [Any.Type] = [InvitationRepository.self]

    static func makeService(for worker: Container) throws -> Self {
        return .init(try worker.connectionPool(to: .mysql))
    }

}
