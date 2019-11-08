import Vapor

import Foundation

final class ItemsSorting: EntitySorting<Item> {}

protocol ItemRepository: EntityRepository {

    func find(by id: Item.ID) -> EventLoopFuture<Item?>
    func find(by id: Item.ID, in list: List) throws -> EventLoopFuture<Item?>

    func findWithReservation(by id: Item.ID, in list: List)
        throws -> EventLoopFuture<(Item, Reservation?)?>

    func all() -> EventLoopFuture<[Item]>

    func all(for list: List) throws -> EventLoopFuture<[Item]>
    func all(for list: List, sort: ItemsSorting) throws -> EventLoopFuture<[Item]>

    func allAndReservations(for list: List)
        throws -> EventLoopFuture<[(Item, Reservation?)]>
    func allAndReservations(for list: List, sort: ItemsSorting)
        throws -> EventLoopFuture<[(Item, Reservation?)]>

    func count(on list: List) throws -> EventLoopFuture<Int>

    func save(item: Item) -> EventLoopFuture<Item>
}
