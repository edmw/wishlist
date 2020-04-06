import Foundation

public protocol FavoriteModel {
    var id: FavoriteID? { get }
    var notifications: Favorite.Notifications { get }
    var userID: UserID { get }
    var listID: ListID { get }
}
