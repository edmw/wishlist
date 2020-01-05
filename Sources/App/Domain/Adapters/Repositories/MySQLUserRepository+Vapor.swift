import Domain

import Vapor

// MARK: MySQLUserRepository

/// Adapter for the domain layers `UserRepository` to be used with Vapor.
///
/// This adds the functionality needed that this repository can be injected by Vapor‘s dependency
/// injection framework.
extension MySQLUserRepository: ServiceType {

    // MARK: Service

    static let serviceSupports: [Any.Type] = [UserRepository.self]

    static func makeService(for worker: Container) throws -> Self {
        return .init(try worker.connectionPool(to: .mysql))
    }

}
