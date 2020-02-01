// sourcery:inline:FluentUserRepository.AutoRepositoryService

// MARK: DO NOT EDIT

import Domain

import Vapor

// MARK: FluentUserRepository

/// Adapter for the domain layers `FluentUserRepository` to be used with Vapor.
///
/// This adds the functionality needed that this repository can be injected by Vapor‘s dependency
/// injection framework.
extension FluentUserRepository: ServiceType {

    // MARK: Service

    public static let serviceSupports: [Any.Type] = [UserRepository.self]

    public static func makeService(for worker: Container) throws -> Self {
        return .init(try worker.connectionPool(to: .mysql))
    }

}
// sourcery:end
