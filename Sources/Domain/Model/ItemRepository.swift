import NIO

// MARK: ItemRepository

public final class ItemsSorting: EntitySorting<Item> {}

public protocol ItemRepository: EntityRepository {

    var sortingDefault: ItemsSorting { get }

    func find(by id: ItemID) -> EventLoopFuture<Item?>
    func find(by id: ItemID, in list: List) throws -> EventLoopFuture<Item?>

    func findWithReservation(by id: ItemID, in list: List)
        throws -> EventLoopFuture<(Item, Reservation?)?>

    func findAndListAndUser(by id: ItemID, in listid: ListID, for userid: UserID)
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

extension ItemRepository {

    public var sortingDefault: ItemsSorting {
        return ItemsSorting(\Item.title, .ascending)
    }

}
