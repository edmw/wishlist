// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Domain

import Vapor

// MARK: MySQLFavoriteRepository

/// Adapter for the domain layers `MySQLFavoriteRepository` to be used with Vapor.
///
/// This adds the functionality needed that this repository can be injected by Vapor‘s dependency
/// injection framework.
extension MySQLFavoriteRepository: ServiceType {

    // MARK: Service

    public static let serviceSupports: [Any.Type] = [FavoriteRepository.self]

    public static func makeService(for worker: Container) throws -> Self {
        return .init(try worker.connectionPool(to: .mysql))
    }

}
