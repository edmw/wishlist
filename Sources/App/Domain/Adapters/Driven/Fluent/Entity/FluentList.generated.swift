// sourcery:inline:FluentList.AutoFluentEntity
// swiftlint:disable superfluous_disable_command
// swiftlint:disable cyclomatic_complexity

// MARK: DO NOT EDIT

import Domain

import Vapor
import Fluent
import FluentMySQL

// MARK: FluentList

/// This generated type is based on the Domain‘s FluentList model type and is used for
/// storing data to and retrieving data from a SQL database using Fluent.
public struct FluentList: ListModel,
    Fluent.Model,
    Fluent.Migration,
    Equatable
{
    // MARK: Fluent.Model

    public typealias Database = MySQLDatabase
    public typealias ID = UUID
    public static let idKey: IDKey = \.id
    public static let name = "List"
    public static let migrationName = "List"

    public var id: UUID?
    public var title: Title
    public var visibility: Visibility
    public var createdAt: Date
    public var modifiedAt: Date
    public var options: List.Options
    public var itemsSorting: ItemsSorting?
    public var userID: UUID

    init(
        id: UUID?,
        title: Title,
        visibility: Visibility,
        createdAt: Date,
        modifiedAt: Date,
        options: List.Options,
        itemsSorting: ItemsSorting?,
        userID: UUID
    ) {
        self.id = id
        self.title = title
        self.visibility = visibility
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.options = options
        self.itemsSorting = itemsSorting
        self.userID = userID
    }

    // MARK: Fluent.Migration

    public static func prepare(on connection: Database.Connection) -> EventLoopFuture<Void> {
        return Database.create(self, on: connection) { builder in
            builder.field(for: \.id)
            builder.field(for: \.title)
            builder.field(for: \.visibility)
            builder.field(for: \.createdAt)
            builder.field(for: \.modifiedAt)
            builder.field(for: \.options)
            builder.field(for: \.itemsSorting)
            builder.field(for: \.userID)
            builder.reference(from: \.userID, to: \FluentUser.id, onDelete: .cascade)
        }
    }

    // MARK: Relations

    var user: Parent<FluentList, FluentUser> {
        return parent(\FluentList.userID)
    }

    func requireUser(on container: Container) throws -> EventLoopFuture<User> {
        return container.withPooledConnection(to: .mysql) { connection in
            return self.user.get(on: connection).mapToEntity()
        }
    }

    var items: Children<FluentList, FluentItem> {
        return children(\FluentItem.listID)
    }

    // MARK: Equatable

    public static func == (lhs: FluentList, rhs: FluentList) -> Bool {
        guard lhs.id == rhs.id else {
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
        guard lhs.userID == rhs.userID else {
            return false
        }
        return true
    }

}

// MARK: - List

extension List {

    var model: FluentList {
        return .init(
            id: id,
            title: title,
            visibility: visibility,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
            options: options,
            itemsSorting: itemsSorting,
            userID: userID
        )
    }

}

// MARK: - EventLoopFuture

extension EventLoopFuture where Expectation == FluentList? {

    func mapToEntity() -> EventLoopFuture<List?> {
        return self.map { model in
            guard let model = model else {
                return nil
            }
            return List(from: model)
        }
    }

}

extension EventLoopFuture where Expectation == FluentList {

    func mapToEntity() -> EventLoopFuture<List> {
        return self.map { model in
            return List(from: model)
        }
    }

}

extension EventLoopFuture where Expectation == [FluentList] {

    func mapToEntities() -> EventLoopFuture<[List]> {
        return self.map { models in
            return models.map { model in List(from: model) }
        }
    }

}
// sourcery:end
