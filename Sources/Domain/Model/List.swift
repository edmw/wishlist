import Foundation

import Library

// MARK: Entity

/// List model
/// This type represents a user’s wishlist.
///
/// Relations:
/// - Parent: User
/// - Childs: Items
public final class List: ListModel, Viewable,
    Entity,
    EntityDetachable,
    EntityReflectable,
    Loggable,
    Codable,
    CustomStringConvertible,
    CustomDebugStringConvertible
{

    // maximum number of lists per user:
    // this is a hard limit (application can have soft limits, too)
    public static let maximumNumberOfListsPerUser = 1_000

    public static let minimumLengthOfTitle = 4
    public static let maximumLengthOfTitle = 100

    public var id: ListID?

    public var title: Title
    public var visibility: Visibility
    public var createdAt: Date
    public var modifiedAt: Date
    public var options: List.Options

    public var itemsSorting: ItemsSorting?

    /// Parent
    public var userID: UserID

    public init<T: ListModel>(from other: T) {
        self.id = other.id

        self.title = other.title
        self.visibility = other.visibility
        self.createdAt = other.createdAt
        self.modifiedAt = other.modifiedAt
        self.options = other.options

        self.itemsSorting = other.itemsSorting

        self.userID = other.userID
    }

    init(
        id: ListID? = nil,
        title: Title,
        visibility: Visibility,
        user: User
    ) throws {
        guard let userid = user.id else {
            throw EntityError<User>.requiredIDMissing
        }

        self.id = id

        self.title = title
        self.visibility = visibility
        self.createdAt = Date()
        self.modifiedAt = self.createdAt
        self.options = []

        self.userID = userid
    }

    var values: ListValues { .init(self) }

    // MARK: EntityReflectable

    public static var properties: EntityProperties<List> = .build(
        .init(\List.id, label: "id"),
        .init(\List.title, label: "title"),
        .init(\List.visibility, label: "visibility"),
        .init(\List.createdAt, label: "createdAt"),
        .init(\List.modifiedAt, label: "modifiedAt"),
        .init(\List.options, label: "options"),
        .init(\List.itemsSorting, label: "itemsSorting"),
        .init(\List.userID, label: "userID")
    )

    // MARK: CustomStringConvertible

    public var description: String {
        return "List[\(id ??? "???")]"
    }

    // MARK: CustomDebugStringConvertible

    public var debugDescription: String {
        return "List[\(id ??? "???")](\(title))"
    }

    // MARK: - Options

    public struct Options: OptionSet, Codable {
        public let rawValue: Int16

        public static let maskReservations = List.Options(rawValue: 1 << 0)

        public init(rawValue: Int16) {
            self.rawValue = rawValue
        }
    }

}
