// sourcery:inline:FluentList.AutoFluentEntity
// swiftlint:disable superfluous_disable_command
// swiftlint:disable cyclomatic_complexity

// MARK: DO NOT EDIT

import Domain

import Vapor
import Fluent
import FluentMySQL

// MARK: FluentList

/// This generated type is based on the Domain‘s List model type and is used for
/// storing data into and retrieving data from a SQL database using Fluent.
///
/// The Domain builds relations between models using model identifiers (UserID, ListID, ...).
/// This will translate model identifiers to UUIDs and vice versa to handle relations using UUIDs.
public struct FluentList: ListModel,
    Fluent.Model,
    Fluent.Migration,
    Equatable
{
    // MARK: Fluent.Model

    public typealias Database = MySQLDatabase
    public typealias ID = UUID
    public static let idKey: IDKey = \.uuid
    public static let name = "List"
    public static let migrationName = "List"

    public var uuid: UUID?
    public var id: ListID? { ListID(uuid: uuid) }
    public var title: Title
    public var visibility: Visibility
    public var createdAt: Date
    public var modifiedAt: Date
    public var options: List.Options
    public var itemsSorting: ItemsSorting?
    public var userKey: UUID
    public var userID: UserID { UserID(uuid: userKey) }

    /// Initializes a SQL layer's `FluentList`. Usually not called directly.
    /// To create this object a getter `model` is provided on the Domain entity `List`.
    init(
        uuid: UUID?,
        title: Title,
        visibility: Visibility,
        createdAt: Date,
        modifiedAt: Date,
        options: List.Options,
        itemsSorting: ItemsSorting?,
        userKey: UUID
    ) {
        self.uuid = uuid
        self.title = title
        self.visibility = visibility
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.options = options
        self.itemsSorting = itemsSorting
        self.userKey = userKey
    }

    enum CodingKeys: String, CodingKey {
        case uuid = "id"
        case title
        case visibility
        case createdAt
        case modifiedAt
        case options
        case itemsSorting
        case userKey = "userID"
    }

    // MARK: Fluent.Migration

    public static func prepare(on connection: Database.Connection) -> EventLoopFuture<Void> {
        return Database.create(self, on: connection) { builder in
            builder.field(for: \.uuid)
            builder.field(for: \.title)
            builder.field(for: \.visibility)
            builder.field(for: \.createdAt)
            builder.field(for: \.modifiedAt)
            builder.field(for: \.options)
            builder.field(for: \.itemsSorting)
            builder.field(for: \.userKey)
            builder.reference(from: \.userKey, to: \FluentUser.uuid, onDelete: .cascade)
        }
    }

    // MARK: Relations

    var user: Parent<FluentList, FluentUser> {
        return parent(\FluentList.userKey)
    }

    func requireUser(on container: Container) throws -> EventLoopFuture<User> {
        return container.withPooledConnection(to: .mysql) { connection in
            return self.user.get(on: connection).mapToEntity()
        }
    }

    var items: Children<FluentList, FluentItem> {
        return children(\FluentItem.listKey)
    }

    // MARK: Equatable

    public static func == (lhs: FluentList, rhs: FluentList) -> Bool {
        guard lhs.uuid == rhs.uuid else {
            return false
        }
        guard lhs.title == rhs.title else {
            return false
        }
        guard lhs.visibility == rhs.visibility else {
            return false
        }
        guard lhs.createdAt == rhs.createdAt else {
            return false
        }
        guard lhs.modifiedAt == rhs.modifiedAt else {
            return false
        }
        guard lhs.options == rhs.options else {
            return false
        }
        guard lhs.itemsSorting == rhs.itemsSorting else {
            return false
        }
        guard lhs.userKey == rhs.userKey else {
            return false
        }
        return true
    }

}

// MARK: - List

extension List {

    var model: FluentList {
        return .init(
            uuid: id?.uuid,
            title: title,
            visibility: visibility,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
            options: options,
            itemsSorting: itemsSorting,
            userKey: userID.uuid
        )
    }

}

// MARK: - EventLoopFuture

extension EventLoopFuture where Expectation == FluentList {

    /// Maps this future‘s expectation from an SQL layer's `FluentList`
    /// to the Domain entity `List`.
    func mapToEntity() -> EventLoopFuture<List> {
        return self.map { model in
            return List(from: model)
        }
    }

}

extension EventLoopFuture where Expectation == FluentList? {

    /// Maps this future‘s expectation from an SQL layer's optional `FluentList`
    /// to the optional Domain entity `List`.
    func mapToEntity() -> EventLoopFuture<List?> {
        return self.map { model in
            guard let model = model else {
                return nil
            }
            return List(from: model)
        }
    }

}

extension EventLoopFuture where Expectation == [FluentList] {

    /// Maps this future‘s expectation from an array of SQL layer's `FluentList`s
    /// to an array of the Domain entities `List`s.
    func mapToEntities() -> EventLoopFuture<[List]> {
        return self.map { models in
            return models.map { model in List(from: model) }
        }
    }

}
// sourcery:end
