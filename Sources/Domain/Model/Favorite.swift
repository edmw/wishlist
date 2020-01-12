import Library

import Foundation

// MARK: Entity

/// Favorite model
/// This type represents a relation between users and lists:
/// - a user has some favorite lists
/// - a list is favored by some users
///
/// Relations:
/// - Sibling: User
/// - Sibling: List
public final class Favorite: Entity,
    EntityDetachable,
    EntityReflectable,
    Codable,
    Loggable,
    CustomStringConvertible,
    CustomDebugStringConvertible
{
    // maximum number of favorites per user:
    // this is a hard limit (application can have soft limits, too)
    public static let maximumNumberOfFavoritesPerUser = 100

    public var id: UUID? {
        didSet { favoriteID = FavoriteID(uuid: id) }
    }
    public lazy var favoriteID = FavoriteID(uuid: id)

    public var userID: UUID
    public var listID: UUID

    public init(_ user: User, _ list: List) throws {
        guard let userid = user.userID else {
            throw EntityError<User>.requiredIDMissing
        }
        guard let listid = list.listID else {
            throw EntityError<List>.requiredIDMissing
        }
        userID = userid.uuid
        listID = listid.uuid
    }

    // MARK: EntityReflectable

    public static var properties: EntityProperties<Favorite> = .build(
        .init(\Favorite.id, label: "id"),
        .init(\Favorite.userID, label: "userID"),
        .init(\Favorite.listID, label: "listID")
    )

    // MARK: CustomStringConvertible

    public var description: String {
        return "Favorite[\(id ??? "???"):\(favoriteID ??? "???")]" +
            "[user:\(userID)|list:\(listID)]"
    }

    // MARK: CustomDebugStringConvertible

    public var debugDescription: String {
        return "Favorite[\(id ??? "???"):\(favoriteID ??? "???")]" +
            "[user:\(userID)|list:\(listID)]"
    }

}
