// sourcery:inline:FluentFavorite.AutoFluentEntity
// swiftlint:disable superfluous_disable_command
// swiftlint:disable cyclomatic_complexity

// MARK: DO NOT EDIT

import Domain

import Vapor
import Fluent
import FluentMySQL

// MARK: FluentFavorite

/// This generated type is based on the Domain‘s Favorite model type and is used for
/// storing data into and retrieving data from a SQL database using Fluent.
///
/// The Domain builds relations between models using model identifiers (UserID, ListID, ...).
/// This will translate model identifiers to UUIDs and vice versa to handle relations using UUIDs.
public struct FluentFavorite: FavoriteModel,
    Fluent.Model,
    Fluent.Migration,
    Fluent.ModifiablePivot,
    Equatable
{
    // MARK: Fluent.Model

    public typealias Database = MySQLDatabase
    public typealias ID = UUID
    public static let idKey: IDKey = \.uuid
    public static let name = "Favorite"
    public static let migrationName = "Favorite"

    public var uuid: UUID?
    public var id: FavoriteID? { FavoriteID(uuid: uuid) }
    public var userKey: UUID
    public var userID: UserID { UserID(uuid: userKey) }
    public var listKey: UUID
    public var listID: ListID { ListID(uuid: listKey) }

    /// Initializes a SQL layer's `FluentFavorite`. Usually not called directly.
    /// To create this object a getter `model` is provided on the Domain entity `Favorite`.
    init(
        uuid: UUID?,
        userKey: UUID,
        listKey: UUID
    ) {
        self.uuid = uuid
        self.userKey = userKey
        self.listKey = listKey
    }

    enum CodingKeys: String, CodingKey {
        case uuid = "id"
        case userKey = "userID"
        case listKey = "listID"
    }

    // MARK: Fluent.Pivot

    public typealias Left = FluentUser
    public typealias Right = FluentList

    public static var leftIDKey: LeftIDKey = \FluentFavorite.userKey
    public static var rightIDKey: RightIDKey = \FluentFavorite.listKey

    public init(_ left: FluentUser, _ right: FluentList) throws {
        guard let leftid = left.id else {
            throw FluentFavoriteError.requiredUserIDMissing
        }
        guard let rightid = right.id else {
            throw FluentFavoriteError.requiredListIDMissing
        }
        self.userKey = leftid.uuid
        self.listKey = rightid.uuid
    }

    // MARK: Fluent.Migration

    public static func prepare(on connection: Database.Connection) -> EventLoopFuture<Void> {
        return Database.create(self, on: connection) { builder in
            builder.field(for: \.uuid)
            builder.field(for: \.userKey)
            builder.field(for: \.listKey)
        }
    }

    // MARK: Equatable

    public static func == (lhs: FluentFavorite, rhs: FluentFavorite) -> Bool {
        guard lhs.uuid == rhs.uuid else {
            return false
        }
        guard lhs.userKey == rhs.userKey else {
            return false
        }
        guard lhs.listKey == rhs.listKey else {
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
            uuid: id?.uuid,
            userKey: userID.uuid,
            listKey: listID.uuid
        )
    }

}

// MARK: - EventLoopFuture

extension EventLoopFuture where Expectation == FluentFavorite {

    /// Maps this future‘s expectation from an SQL layer's `FluentFavorite`
    /// to the Domain entity `Favorite`.
    func mapToEntity() -> EventLoopFuture<Favorite> {
        return self.map { model in
            return Favorite(from: model)
        }
    }

}

extension EventLoopFuture where Expectation == FluentFavorite? {

    /// Maps this future‘s expectation from an SQL layer's optional `FluentFavorite`
    /// to the optional Domain entity `Favorite`.
    func mapToEntity() -> EventLoopFuture<Favorite?> {
        return self.map { model in
            guard let model = model else {
                return nil
            }
            return Favorite(from: model)
        }
    }

}

extension EventLoopFuture where Expectation == [FluentFavorite] {

    /// Maps this future‘s expectation from an array of SQL layer's `FluentFavorite`s
    /// to an array of the Domain entities `Favorite`s.
    func mapToEntities() -> EventLoopFuture<[Favorite]> {
        return self.map { models in
            return models.map { model in Favorite(from: model) }
        }
    }

}
// sourcery:end
