// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Domain

import Vapor

// MARK: MySQLItemRepository

/// Adapter for the domain layers `MySQLItemRepository` to be used with Vapor.
///
/// This adds the functionality needed that this repository can be injected by Vapor‘s dependency
/// injection framework.
extension MySQLItemRepository: ServiceType {

    // MARK: Service

    public static let serviceSupports: [Any.Type] = [ItemRepository.self]

    public static func makeService(for worker: Container) throws -> Self {
        return .init(try worker.connectionPool(to: .mysql))
    }

}
