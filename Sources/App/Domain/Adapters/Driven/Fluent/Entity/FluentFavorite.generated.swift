// sourcery:inline:FluentFavorite.AutoFluentEntity
// swiftlint:disable superfluous_disable_command
// swiftlint:disable cyclomatic_complexity

// MARK: DO NOT EDIT

import Domain

import Vapor
import Fluent
import FluentMySQL

// MARK: FluentFavorite

/// This generated type is based on the Domain‘s FluentFavorite model type and is used for
/// storing data to and retrieving data from a SQL database using Fluent.
public struct FluentFavorite: FavoriteModel,
    Fluent.Model,
    Fluent.Migration,
    Fluent.ModifiablePivot,
    Equatable
{
    // MARK: Fluent.Model

    public typealias Database = MySQLDatabase
    public typealias ID = UUID
    public static let idKey: IDKey = \.id
    public static let name = "Favorite"
    public static let migrationName = "Favorite"

    public var id: UUID?
    public var userID: UUID
    public var listID: UUID

    init(
        id: UUID?,
        userID: UUID,
        listID: UUID
    ) {
        self.id = id
        self.userID = userID
        self.listID = listID
    }

    // MARK: Fluent.Pivot

    public typealias Left = FluentUser
    public typealias Right = FluentList

    public static var leftIDKey: LeftIDKey = \FluentFavorite.userID
    public static var rightIDKey: RightIDKey = \FluentFavorite.listID

    public init(_ left: FluentUser, _ right: FluentList) throws {
        guard let leftid = left.id else {
            throw FluentFavoriteError.requiredUserIDMissing
        }
        guard let rightid = right.id else {
            throw FluentFavoriteError.requiredListIDMissing
        }
        self.userID = leftid
        self.listID = rightid
    }

    // MARK: Fluent.Migration

    public static func prepare(on connection: Database.Connection) -> EventLoopFuture<Void> {
        return Database.create(self, on: connection) { builder in
            builder.field(for: \.id)
            builder.field(for: \.userID)
            builder.field(for: \.listID)
        }
    }

    // MARK: Equatable

    public static func == (lhs: FluentFavorite, rhs: FluentFavorite) -> Bool {
        guard lhs.id == rhs.id else {
            return false
        }
        guard lhs.userID == rhs.userID else {
            return false
        }
        guard lhs.listID == rhs.listID else {
            return false
        }
        return true
    }

}

enum FluentFavoriteError: Error {
    case requiredUserIDMissing
    case requiredListIDMissing
}

// MARK: Siblings

extension FluentUser {

    // this User's favorite lists
    var favorites: Siblings<FluentUser, FluentList, FluentFavorite> {
        return siblings()
    }

}

extension FluentList {

    // all Users that favorite this list
    var users: Siblings<FluentList, FluentUser, FluentFavorite> {
        return siblings()
    }

}

// MARK: - Favorite

extension Favorite {

    var model: FluentFavorite {
        return .init(
            id: id,
            userID: userID,
            listID: listID
        )
    }

}

// MARK: - EventLoopFuture

extension EventLoopFuture where Expectation == FluentFavorite? {

    func mapToEntity() -> EventLoopFuture<Favorite?> {
        return self.map { model in
            guard let model = model else {
                return nil
            }
            return Favorite(from: model)
        }
    }

}

extension EventLoopFuture where Expectation == FluentFavorite {

    func mapToEntity() -> EventLoopFuture<Favorite> {
        return self.map { model in
            return Favorite(from: model)
        }
    }

}

extension EventLoopFuture where Expectation == [FluentFavorite] {

    func mapToEntities() -> EventLoopFuture<[Favorite]> {
        return self.map { models in
            return models.map { model in Favorite(from: model) }
        }
    }

}
// sourcery:end
