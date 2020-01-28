// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Domain

import Vapor

// MARK: MySQLUserRepository

/// Adapter for the domain layers `MySQLUserRepository` to be used with Vapor.
///
/// This adds the functionality needed that this repository can be injected by Vapor‘s dependency
/// injection framework.
extension MySQLUserRepository: ServiceType {

    // MARK: Service

    public static let serviceSupports: [Any.Type] = [UserRepository.self]

    public static func makeService(for worker: Container) throws -> Self {
        return .init(try worker.connectionPool(to: .mysql))
    }

}
