import Vapor
import Fluent
import FluentMySQL

// MARK: Entity

/// List model
/// This type represents an user’s wishlist.
///
/// Relations:
/// - Parent: User
/// - Childs: Items
final class List: Entity, EntityReflectable, Content, Viewable, CustomStringConvertible {

    var id: UUID?

    var name: String
    var visibility: Visibility
    var createdAt: Date
    var modifiedAt: Date

    var itemsSorting: ItemsSorting?

    /// Parent
    var userID: User.ID

    init(
        id: UUID? = nil,
        name: String,
        visibility: Visibility,
        user: User
    ) throws {
        self.id = id

        self.name = name
        self.visibility = visibility
        self.createdAt = Date()
        self.modifiedAt = self.createdAt

        self.userID = try user.requireID()
    }

    // maximum number of lists per user:
    // this is a hard limit (application can have soft limits, too)
    static let maximumNumberOfListsPerUser = 1_000

    static let minimumLengthOfName = 4
    static let maximumLengthOfName = 100

    // MARK: EntityReflectable

    static var properties: [PartialKeyPath<List>] = [
        \List.id,
        \List.name,
        \List.visibility,
        \List.createdAt,
        \List.modifiedAt,
        \List.itemsSorting,
        \List.userID
    ]

    static func propertyName(forKey keyPath: PartialKeyPath<List>) -> String? {
        switch keyPath {
        case \List.id: return "id"
        case \List.name: return "name"
        case \List.visibility: return "visibility"
        case \List.createdAt: return "createdAt"
        case \List.modifiedAt: return "modifiedAt"
        case \List.items: return "itemsSorting"
        case \List.userID: return "userID"
        default: return nil
        }
    }

    // MARK: CustomStringConvertible

    var description: String {
        return "List[\(id ??? "???")](\(name))"
    }

}
