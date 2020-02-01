// sourcery:inline:FluentInvitationRepository.AutoRepositoryService

// MARK: DO NOT EDIT

import Domain

import Vapor

// MARK: FluentInvitationRepository

/// Adapter for the domain layers `FluentInvitationRepository` to be used with Vapor.
///
/// This adds the functionality needed that this repository can be injected by Vapor‘s dependency
/// injection framework.
extension FluentInvitationRepository: ServiceType {

    // MARK: Service

    public static let serviceSupports: [Any.Type] = [InvitationRepository.self]

    public static func makeService(for worker: Container) throws -> Self {
        return .init(try worker.connectionPool(to: .mysql))
    }

}
// sourcery:end
