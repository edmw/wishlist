import Domain

import Vapor

// MARK: MySQLItemRepository

/// Adapter for the domain layers `ItemRepository` to be used with Vapor.
///
/// This adds the functionality needed that this repository can be injected by Vapor‘s dependency
/// injection framework.
extension MySQLItemRepository: ServiceType {

    // MARK: - Service

    static let serviceSupports: [Any.Type] = [ItemRepository.self]

    static func makeService(for worker: Container) throws -> Self {
        return .init(try worker.connectionPool(to: .mysql))
    }

}
