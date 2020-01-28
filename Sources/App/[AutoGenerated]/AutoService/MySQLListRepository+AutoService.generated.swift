// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Domain

import Vapor

// MARK: MySQLListRepository

/// Adapter for the domain layers `MySQLListRepository` to be used with Vapor.
///
/// This adds the functionality needed that this repository can be injected by Vapor‘s dependency
/// injection framework.
extension MySQLListRepository: ServiceType {

    // MARK: Service

    public static let serviceSupports: [Any.Type] = [ListRepository.self]

    public static func makeService(for worker: Container) throws -> Self {
        return .init(try worker.connectionPool(to: .mysql))
    }

}
