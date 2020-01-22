import Foundation

import Library

// MARK: Entity

/// List model
/// This type represents a user’s wishlist.
///
/// Relations:
/// - Parent: User
/// - Childs: Items
public final class List: Entity, Viewable,
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

    public var id: UUID? {
        didSet { listID = ListID(uuid: id) }
    }
    public lazy var listID = ListID(uuid: id)

    public var title: String
    public var visibility: Visibility
    public var createdAt: Date
    public var modifiedAt: Date
    public var options: List.Options

    public var itemsSorting: ItemsSorting?

    /// Parent
    public var userID: UUID

    init(
        id: ListID? = nil,
        title: String,
        visibility: Visibility,
        user: User
    ) throws {
        guard let userid = user.id else {
            throw EntityError<User>.requiredIDMissing
        }

        self.id = id?.uuid

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
        return "List[\(id ??? "???"):\(listID ??? "???")]"
    }

    // MARK: CustomDebugStringConvertible

    public var debugDescription: String {
        return "List[\(id ??? "???"):\(listID ??? "???")](\(title))"
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
