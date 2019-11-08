import Vapor

import Foundation

protocol FavoriteRepository: EntityRepository {

    func find(by id: Favorite.ID, for user: User) throws -> EventLoopFuture<Favorite?>
    func find(favorite list: List, for user: User) throws -> EventLoopFuture<Favorite?>

    func favorites(for user: User) throws -> EventLoopFuture<[List]>
    func favorites(for user: User, sort: ListsSorting) throws -> EventLoopFuture<[List]>

    func addFavorite(_ list: List, for user: User) throws -> EventLoopFuture<Favorite>

}
