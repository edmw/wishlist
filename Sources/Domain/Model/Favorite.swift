import Foundation

import Library

// MARK: Entity

/// Favorite model
/// This type represents a relation between users and lists:
/// - a user has some favorite lists
/// - a list is favored by some users
///
/// Relations:
/// - Sibling: User
/// - Sibling: List
public final class Favorite: FavoriteModel,
    Entity,
    EntityDetachable,
    EntityReflectable,
    Loggable,
    Codable,
    CustomStringConvertible,
    CustomDebugStringConvertible
{
    // maximum number of favorites per user:
    // this is a hard limit (application can have soft limits, too)
    public static let maximumNumberOfFavoritesPerUser = 100

    public var id: FavoriteID?

    public var userID: UserID
    public var listID: ListID

    public init<T: FavoriteModel>(from other: T) {
        self.id = other.id
        self.userID = other.userID
        self.listID = other.listID
    }

    public init(
        id: FavoriteID? = nil,
        userID: UserID,
        listID: ListID
    ) {
        self.id = id
        self.userID = userID
        self.listID = listID
    }

    // MARK: EntityReflectable

    public static var properties: EntityProperties<Favorite> = .build(
        .init(\Favorite.id, label: "id"),
        .init(\Favorite.userID, label: "userID"),
        .init(\Favorite.listID, label: "listID")
    )

    // MARK: CustomStringConvertible

    public var description: String {
        return "Favorite[\(id ??? "???")](user:\(userID)|list:\(listID))"
    }

    // MARK: CustomDebugStringConvertible

    public var debugDescription: String {
        return "Favorite[\(id ??? "???")](user:\(userID)|list:\(listID))"
    }

}
