// sourcery:inline:FluentListRepository.AutoRepositoryService

// MARK: DO NOT EDIT

import Domain

import Vapor

// MARK: FluentListRepository

/// Adapter for the domain layers `FluentListRepository` to be used with Vapor.
///
/// This adds the functionality needed that this repository can be injected by Vapor‘s dependency
/// injection framework.
extension FluentListRepository: ServiceType {

    // MARK: Service

    public static let serviceSupports: [Any.Type] = [ListRepository.self]

    public static func makeService(for worker: Container) throws -> Self {
        return .init(try worker.connectionPool(to: .mysql))
    }

}
// sourcery:end
