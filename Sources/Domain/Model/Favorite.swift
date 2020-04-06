import Foundation

import Library

// MARK: Favorite

/// Favorite model
/// This type represents a relation between users and lists:
/// - a user has some favorite lists
/// - a list is favored by some users
///
/// Relations:
/// - Sibling: User
/// - Sibling: List
public final class Favorite: FavoriteModel, Representable,
    DomainEntity,
    DomainEntityDetachable,
    DomainEntityReflectable,
    Loggable,
    Codable,
    CustomStringConvertible,
    CustomDebugStringConvertible
{
    // MARK: Entity

    // maximum number of favorites per user:
    // this is a hard limit (application can have soft limits, too)
    public static let maximumNumberOfFavoritesPerUser = 100

    public internal(set) var id: FavoriteID?
    public internal(set) var notifications: Favorite.Notifications = []

    public internal(set) var userID: UserID
    public internal(set) var listID: ListID

    public init<T: FavoriteModel>(from other: T) {
        self.id = other.id
        self.notifications = other.notifications
        self.userID = other.userID
        self.listID = other.listID
    }

    init(
        id: FavoriteID? = nil,
        userID: UserID,
        listID: ListID
    ) {
        self.id = id
        self.notifications = []
        self.userID = userID
        self.listID = listID
    }

    // MARK: EntityReflectable

    public static var properties: EntityProperties<Favorite> = .build(
        .init(\Favorite.id, label: "id"),
        .init(\Favorite.notifications, label: "notifications"),
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

    // MARK: - Notifications

    public struct Notifications: OptionSet,
        Codable,
        Equatable,
        Hashable,
        LosslessStringConvertible,
        CustomStringConvertible
    {

        public let rawValue: Int16

        public static let itemCreated = Favorite.Notifications(rawValue: 1 << 0)

        public init(rawValue: Int16) {
            self.rawValue = rawValue
        }

        public init?(string: String) {
            guard let rawValue = Int16(string) else {
                return nil
            }
            self.rawValue = rawValue
        }

        public init?(_ description: String) {
            self.init(string: description)
        }

        public var description: String {
            return String(rawValue)
        }

    }

}
