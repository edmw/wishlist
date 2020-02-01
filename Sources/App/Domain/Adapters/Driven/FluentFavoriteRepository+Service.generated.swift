// sourcery:inline:FluentFavoriteRepository.AutoRepositoryService

// MARK: DO NOT EDIT

import Domain

import Vapor

// MARK: FluentFavoriteRepository

/// Adapter for the domain layers `FluentFavoriteRepository` to be used with Vapor.
///
/// This adds the functionality needed that this repository can be injected by Vapor‘s dependency
/// injection framework.
extension FluentFavoriteRepository: ServiceType {

    // MARK: Service

    public static let serviceSupports: [Any.Type] = [FavoriteRepository.self]

    public static func makeService(for worker: Container) throws -> Self {
        return .init(try worker.connectionPool(to: .mysql))
    }

}
// sourcery:end
