import Domain

import Vapor

// MARK: MySQLListRepository

/// Adapter for the domain layers `ListRepository` to be used with Vapor.
///
/// This adds the functionality needed that this repository can be injected by Vapor‘s dependency
/// injection framework.
extension MySQLListRepository: ServiceType {

    // MARK: Service

    static let serviceSupports: [Any.Type] = [ListRepository.self]

    static func makeService(for worker: Container) throws -> Self {
        return .init(try worker.connectionPool(to: .mysql))
    }

}
