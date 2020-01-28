// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Domain

import Vapor

// MARK: MySQLInvitationRepository

/// Adapter for the domain layers `MySQLInvitationRepository` to be used with Vapor.
///
/// This adds the functionality needed that this repository can be injected by Vapor‘s dependency
/// injection framework.
extension MySQLInvitationRepository: ServiceType {

    // MARK: Service

    public static let serviceSupports: [Any.Type] = [InvitationRepository.self]

    public static func makeService(for worker: Container) throws -> Self {
        return .init(try worker.connectionPool(to: .mysql))
    }

}
