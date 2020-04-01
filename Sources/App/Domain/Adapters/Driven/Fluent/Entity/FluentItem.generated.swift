// sourcery:inline:FluentItem.AutoFluentEntity
// swiftlint:disable superfluous_disable_command
// swiftlint:disable cyclomatic_complexity

// MARK: DO NOT EDIT

import Domain

import Vapor
import Fluent
import FluentMySQL

// MARK: FluentItem

/// This generated type is based on the Domain‘s Item model type and is used for
/// storing data into and retrieving data from a SQL database using Fluent.
///
/// The Domain builds relations between models using model identifiers (UserID, ListID, ...).
/// This will translate model identifiers to UUIDs and vice versa to handle relations using UUIDs.
public struct FluentItem: ItemModel,
    Fluent.Model,
    Fluent.Migration,
    Equatable
{
    // MARK: Fluent.Model

    public typealias Database = MySQLDatabase
    public typealias ID = UUID
    public static let idKey: IDKey = \.uuid
    public static let name = "Item"
    public static let migrationName = "Item"

    public var uuid: UUID?
    public var id: ItemID? { ItemID(uuid: uuid) }
    public var title: Title
    public var text: Text
    public var preference: Item.Preference
    public var url: URL?
    public var imageURL: URL?
    public var createdAt: Date
    public var modifiedAt: Date
    public var archival: Bool
    public var localImageURL: ImageStoreLocator?
    public var listKey: UUID
    public var listID: ListID { ListID(uuid: listKey) }

    /// Initializes a SQL layer's `FluentItem`. Usually not called directly.
    /// To create this object a getter `model` is provided on the Domain entity `Item`.
    init(
        uuid: UUID?,
        title: Title,
        text: Text,
        preference: Item.Preference,
        url: URL?,
        imageURL: URL?,
        createdAt: Date,
        modifiedAt: Date,
        archival: Bool,
        localImageURL: ImageStoreLocator?,
        listKey: UUID
    ) {
        self.uuid = uuid
        self.title = title
        self.text = text
        self.preference = preference
        self.url = url
        self.imageURL = imageURL
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.archival = archival
        self.localImageURL = localImageURL
        self.listKey = listKey
    }

    enum CodingKeys: String, CodingKey {
        case uuid = "id"
        case title
        case text
        case preference
        case url
        case imageURL
        case createdAt
        case modifiedAt
        case archival
        case localImageURL
        case listKey = "listID"
    }

    // MARK: Fluent.Migration

    public static func prepare(on connection: Database.Connection) -> EventLoopFuture<Void> {
        return Database.create(self, on: connection) { builder in
            builder.field(for: \.uuid)
            builder.field(for: \.title)
            builder.field(for: \.text)
            builder.field(for: \.preference)
            builder.field(for: \.url)
            builder.field(for: \.imageURL)
            builder.field(for: \.createdAt)
            builder.field(for: \.modifiedAt)
            builder.field(for: \.archival)
            builder.field(for: \.localImageURL)
            builder.field(for: \.listKey)
            builder.reference(from: \.listKey, to: \FluentList.uuid, onDelete: .cascade)
        }
    }

    // MARK: Relations

    var list: Parent<FluentItem, FluentList> {
        return parent(\FluentItem.listKey)
    }

    func requireList(on container: Container) throws -> EventLoopFuture<List> {
        return container.withPooledConnection(to: .mysql) { connection in
            return self.list.get(on: connection).mapToEntity()
        }
    }

    // MARK: Equatable

    public static func == (lhs: FluentItem, rhs: FluentItem) -> Bool {
        guard lhs.uuid == rhs.uuid else {
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
        guard lhs.archival == rhs.archival else {
            return false
        }
        guard lhs.localImageURL == rhs.localImageURL else {
            return false
        }
        guard lhs.listKey == rhs.listKey else {
            return false
        }
        return true
    }

}

// MARK: - Item

extension Item {

    var model: FluentItem {
        return .init(
            uuid: id?.uuid,
            title: title,
            text: text,
            preference: preference,
            url: url,
            imageURL: imageURL,
            createdAt: createdAt,
            modifiedAt: modifiedAt,
            archival: archival,
            localImageURL: localImageURL,
            listKey: listID.uuid
        )
    }

}

// MARK: - EventLoopFuture

extension EventLoopFuture where Expectation == FluentItem {

    /// Maps this future‘s expectation from an SQL layer's `FluentItem`
    /// to the Domain entity `Item`.
    func mapToEntity() -> EventLoopFuture<Item> {
        return self.map { model in
            return Item(from: model)
        }
    }

}

extension EventLoopFuture where Expectation == FluentItem? {

    /// Maps this future‘s expectation from an SQL layer's optional `FluentItem`
    /// to the optional Domain entity `Item`.
    func mapToEntity() -> EventLoopFuture<Item?> {
        return self.map { model in
            guard let model = model else {
                return nil
            }
            return Item(from: model)
        }
    }

}

extension EventLoopFuture where Expectation == [FluentItem] {

    /// Maps this future‘s expectation from an array of SQL layer's `FluentItem`s
    /// to an array of the Domain entities `Item`s.
    func mapToEntities() -> EventLoopFuture<[Item]> {
        return self.map { models in
            return models.map { model in Item(from: model) }
        }
    }

}
// sourcery:end
