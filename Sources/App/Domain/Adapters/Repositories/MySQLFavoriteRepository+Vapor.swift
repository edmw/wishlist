import Domain

import Vapor

// MARK: MySQLFavoriteRepository

/// Adapter for the domain layers `FavoriteRepository` to be used with Vapor.
///
/// This adds the functionality needed that this repository can be injected by Vapor‘s dependency
/// injection framework.
extension MySQLFavoriteRepository: ServiceType {

    // MARK: Service

    static let serviceSupports: [Any.Type] = [FavoriteRepository.self]

    static func makeService(for worker: Container) throws -> Self {
        return .init(try worker.connectionPool(to: .mysql))
    }

}
