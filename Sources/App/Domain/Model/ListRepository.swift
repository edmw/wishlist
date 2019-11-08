import Vapor

import Foundation

final class ListsSorting: EntitySorting<List> {}

protocol ListRepository: EntityRepository {

    func find(by id: List.ID) -> EventLoopFuture<List?>
    func find(by id: List.ID, for user: User) throws -> EventLoopFuture<List?>
    func find(title: String) -> EventLoopFuture<List?>
    func find(title: String, for user: User) throws -> EventLoopFuture<List?>

    func all() -> EventLoopFuture<[List]>
    func all(for user: User) throws -> EventLoopFuture<[List]>
    func all(for user: User, sort: ListsSorting) throws -> EventLoopFuture<[List]>

    func count(for user: User) throws -> EventLoopFuture<Int>
    func count(title: String, for user: User) throws -> EventLoopFuture<Int>

    func save(list: List) -> EventLoopFuture<List>

    // Returns an available list title for a user based on the specified title.
    func available(title: String, for user: User) throws -> EventLoopFuture<String?>
}
