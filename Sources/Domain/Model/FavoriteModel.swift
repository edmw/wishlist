import Foundation

public protocol FavoriteModel {
    var id: UUID? { get }
    var userID: UUID { get }
    var listID: UUID { get }
}
