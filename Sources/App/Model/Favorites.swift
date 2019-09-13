import Vapor

/// Favorite model
/// This type represents a relation between users and lists:
/// - a user has some favorite lists
/// - a list is favored by some users
///
/// Relations:
/// - Sibling: User
/// - Sibling: List
struct Favorite: Codable {

    var id: UUID?

    var userID: UUID
    var listID: UUID

    init(_ user: User, _ list: List) throws {
        userID = try user.requireID()
        listID = try list.requireID()
    }

    // maximum number of favorites per user:
    // this is a hard limit (application can have soft limits, too)
    static let maximumNumberOfFavoritesPerUser = 100

}
