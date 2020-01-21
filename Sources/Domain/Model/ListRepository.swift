import DomainModel

import Foundation
import NIO

public final class ListsSorting: EntitySorting<List> {}

public protocol ListRepository: EntityRepository {

    func find(by id: ListID) -> EventLoopFuture<List?>
    func find(by id: ListID, for user: User) throws -> EventLoopFuture<List?>
    func find(title: String) -> EventLoopFuture<List?>
    func find(title: String, for user: User) throws -> EventLoopFuture<List?>

    func findWithUser(by id: ListID, for userid: UserID)
        throws -> EventLoopFuture<(List, User)?>

    func all() -> EventLoopFuture<[List]>
    func all(for user: User) throws -> EventLoopFuture<[List]>
    func all(for user: User, sort: ListsSorting) throws -> EventLoopFuture<[List]>

    func count(for user: User) throws -> EventLoopFuture<Int>
    func count(title: String, for user: User) throws -> EventLoopFuture<Int>

    func owner(of list: List) -> EventLoopFuture<User>

    func save(list: List) -> EventLoopFuture<List>

    func delete(list: List, for user: User) throws -> EventLoopFuture<List?>

    // Returns an available list title for a user based on the specified title.
    func available(title: String, for user: User) throws -> EventLoopFuture<String?>

}
