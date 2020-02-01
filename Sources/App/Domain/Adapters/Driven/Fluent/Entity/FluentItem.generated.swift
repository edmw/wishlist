// sourcery:inline:FluentItem.AutoFluentEntity
// swiftlint:disable superfluous_disable_command
// swiftlint:disable cyclomatic_complexity

// MARK: DO NOT EDIT

import Domain

import Vapor
import Fluent
import FluentMySQL

// MARK: FluentItem

/// This generated type is based on the Domain‘s FluentItem model type and is used for
/// storing data to and retrieving data from a SQL database using Fluent.
public struct FluentItem: ItemModel,
    Fluent.Model,
    Fluent.Migration,
    Equatable
{
    // MARK: Fluent.Model

    public typealias Database = MySQLDatabase
    public typealias ID = UUID
    public static let idKey: IDKey = \.id
    public static let name = "Item"
    public static let migrationName = "Item"

    public var id: UUID?
    public var title: Title
    public var text: Text
    public var preference: Item.Preference
    public var url: URL?
    public var imageURL: URL?
    public var createdAt: Date
    public var modifiedAt: Date
    public var localImageURL: URL?
    public var listID: UUID

    init(
        id: UUID?,
        title: Title,
        text: Text,
        preference: Item.Preference,
        url: URL?,
        imageURL: URL?,
        createdAt: Date,
        modifiedAt: Date,
        localImageURL: URL?,
        listID: UUID
    ) {
        self.id = id
        self.title = title
        self.text = text
        self.preference = preference
        self.url = url
        self.imageURL = imageURL
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.localImageURL = localImageURL
        self.listID = listID
    }

    // MARK: Fluent.Migration

    public static func prepare(on connection: Database.Connection) -> EventLoopFuture<Void> {
        return Database.create(self, on: connection) { builder in
            builder.field(for: \.id)
            builder.field(for: \.title)
            builder.field(for: \.text)
            builder.field(for: \.preference)
            builder.field(for: \.url)
            builder.field(for: \.imageURL)
            builder.field(for: \.createdAt)
            builder.field(for: \.modifiedAt)
            builder.field(for: \.localImageURL)
            builder.field(for: \.listID)
            builder.reference(from: \.listID, to: \FluentList.id, onDelete: .cascade)
        }
    }

    // MARK: Relations

    var list: Parent<FluentItem, FluentList> {
        return parent(\FluentItem.listID)
    }

    func requireList(on container: Container) throws -> EventLoopFuture<List> {
        return container.withPooledConnection(to: .mysql) { connection in
            return self.list.get(on: connection).mapToEntity()
        }
    }

    // MARK: Equatable

    public static func == (lhs: FluentItem, rhs: FluentItem) -> Bool {
        guard lhs.id == rhs.id else {
            return false
        }
        guard lhs.title == rhs.title else {
            return false
        }
        guard lhs.text == rhs.text else {
            return false
        }
        guard lhs.preference == rhs.preference else {
            return false
        }
        guard lhs.url == rhs.url else {
            return false
        }
        guard lhs.imageURL == rhs.imageURL else {
            return false
        }
        guard lhs.createdAt == rhs.createdAt else {
            return false
        }
        guard lhs.modifiedAt == rhs.modifiedAt else {
            return false
        }
        guard lhs.localImageURL == rhs.localImageURL else {
            return false
        }
        guard lhs.listID == rhs.listID else {
            return false
        }
        return true
    }

}

// MARK: - Item

extension Item {

    var model: FluentItem {
        return .init(
            id: id,
            title: title,
            text: text,
            preference: preference,
            url: url,
            imageURL: imageURL,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
            localImageURL: localImageURL,
            listID: listID
        )
    }

}

// MARK: - EventLoopFuture

extension EventLoopFuture where Expectation == FluentItem? {

    func mapToEntity() -> EventLoopFuture<Item?> {
        return self.map { model in
            guard let model = model else {
                return nil
            }
            return Item(from: model)
        }
    }

}

extension EventLoopFuture where Expectation == FluentItem {

    func mapToEntity() -> EventLoopFuture<Item> {
        return self.map { model in
            return Item(from: model)
        }
    }

}

extension EventLoopFuture where Expectation == [FluentItem] {

    func mapToEntities() -> EventLoopFuture<[Item]> {
        return self.map { models in
            return models.map { model in Item(from: model) }
        }
    }

}
// sourcery:end
