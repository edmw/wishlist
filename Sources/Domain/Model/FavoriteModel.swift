import Foundation

public protocol FavoriteModel {
    var id: FavoriteID? { get }
    var userID: UserID { get }
    var listID: ListID { get }
}
