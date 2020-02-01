// sourcery:inline:FluentItemRepository.AutoRepositoryService

// MARK: DO NOT EDIT

import Domain

import Vapor

// MARK: FluentItemRepository

/// Adapter for the domain layers `FluentItemRepository` to be used with Vapor.
///
/// This adds the functionality needed that this repository can be injected by Vapor‘s dependency
/// injection framework.
extension FluentItemRepository: ServiceType {

    // MARK: Service

    public static let serviceSupports: [Any.Type] = [ItemRepository.self]

    public static func makeService(for worker: Container) throws -> Self {
        return .init(try worker.connectionPool(to: .mysql))
    }

}
// sourcery:end
