import DomainModel

import Foundation
import NIO

public final class ItemsSorting: EntitySorting<Item> {}

public protocol ItemRepository: EntityRepository {

    func find(by id: ItemID) -> EventLoopFuture<Item?>
    func find(by id: ItemID, in list: List) throws -> EventLoopFuture<Item?>

    func findWithReservation(by id: ItemID, in list: List)
        throws -> EventLoopFuture<(Item, Reservation?)?>

    func findWithListAndUser(by id: ItemID, in listid: ListID, for userid: UserID)
        throws -> EventLoopFuture<(Item, List, User)?>

    func all() -> EventLoopFuture<[Item]>

    func all(for list: List) throws -> EventLoopFuture<[Item]>
    func all(for list: List, sort: ItemsSorting) throws -> EventLoopFuture<[Item]>

    func allAndReservations(for list: List)
        throws -> EventLoopFuture<[(Item, Reservation?)]>
    func allAndReservations(for list: List, sort: ItemsSorting)
        throws -> EventLoopFuture<[(Item, Reservation?)]>

    func count(on list: List) throws -> EventLoopFuture<Int>

    func save(item: Item) -> EventLoopFuture<Item>

    func delete(item: Item, in list: List) throws -> EventLoopFuture<Item?>
    func delete(items: [Item], in list: List) throws -> EventLoopFuture<[Item]>

}
