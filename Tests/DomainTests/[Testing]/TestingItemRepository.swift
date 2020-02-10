@testable import Domain
import Foundation
import NIO

final class TestingItemRepository: ItemRepository {

    let worker: EventLoop

    let listRepository: ListRepository
    let reservationRepository: ReservationRepository
    let userRepository: UserRepository

    init(
        worker: EventLoop,
        listRepository: ListRepository,
        reservationRepository: ReservationRepository,
        userRepository: UserRepository
    ) {
        self.worker = worker
        self.listRepository = listRepository
        self.reservationRepository = reservationRepository
        self.userRepository = userRepository
    }

    private var storage = [ItemID: Item]()

    func find(by id: ItemID) -> EventLoopFuture<Item?> {
        let result = storage[id]
        return worker.newSucceededFuture(result: result)
    }

    func find(by id: ItemID, in list: List) throws -> EventLoopFuture<Item?> {
        let result = storage[id]
        guard result?.listID == list.id else {
            return worker.newSucceededFuture(result: nil)
        }
        return worker.newSucceededFuture(result: result)
    }

    func findWithReservation(by id: ItemID, in list: List) throws
        -> EventLoopFuture<(Item, Reservation?)?>
    {
        return try find(by: id, in: list)
            .flatMap { item in
                guard let item = item else {
                    return self.worker.newSucceededFuture(result: nil)
                }
                return try self.reservationRepository.find(for: item)
                    .map { reservation in
                        return (item, reservation)
                    }
            }
    }

    func findAndListAndUser(by id: ItemID, in listid: ListID, for userid: UserID) throws
        -> EventLoopFuture<(Item, List, User)?>
    {
        return find(by: id)
            .flatMap { item in
                guard let item = item else {
                    return self.worker.newSucceededFuture(result: nil)
                }
                return self.listRepository.find(by: listid)
                    .and(self.userRepository.find(id: userid))
                    .map { list, user in
                        guard let list = list, item.listID == listid else {
                            return nil
                        }
                        guard let user = user, list.userID == userid else {
                            return nil
                        }
                        return (item, list, user)
                    }
            }
    }

    func all() -> EventLoopFuture<[Item]> {
        let result = Array(storage.values)
        return worker.newSucceededFuture(result: result)
    }

    func all(for list: List) throws -> EventLoopFuture<[Item]> {
        return try all(for: list, sort: sortingDefault)
    }

    func all(for list: List, sort: ItemsSorting) throws -> EventLoopFuture<[Item]> {
        guard let listid = list.id else {
            throw EntityError<List>.requiredIDMissing
        }
        let result = Array(storage.values).filter { $0.listID == listid }
        return worker.newSucceededFuture(result: result)
    }

    func allAndReservations(for list: List) throws -> EventLoopFuture<[(Item, Reservation?)]> {
        return try allAndReservations(for: list, sort: sortingDefault)
    }

    func allAndReservations(for list: List, sort: ItemsSorting) throws
        -> EventLoopFuture<[(Item, Reservation?)]>
    {
        return try all(for: list, sort: sort)
            .flatMap { items in
                return try items.compactMap { item in
                    return try self.reservationRepository.find(for: item)
                        .map { reservation in
                            return (item, reservation)
                        }
                }
                .flatten(on: self.worker)
            }
    }

    func count(on list: List) throws -> EventLoopFuture<Int> {
        let result = storage.count
        return worker.newSucceededFuture(result: result)
    }

    func save(item: Item) -> EventLoopFuture<Item> {
        if let id = item.id {
            storage[id] = item
        }
        else {
            item.id = ItemID()
            storage[item.id!] = item
        }
        return worker.newSucceededFuture(result: item)
    }

    func delete(item: Item, in list: List) throws -> EventLoopFuture<Item?> {
        guard let itemid = item.id else {
            throw EntityError<Reservation>.requiredIDMissing
        }
        guard let listid = list.id, listid == item.listID else {
            return worker.newSucceededFuture(result: nil)
        }
        storage.removeValue(forKey: itemid)
        return worker.newSucceededFuture(result: item.detached())
    }

    func delete(items: [Item], in list: List) throws -> EventLoopFuture<[Item]> {
        let result = try items.compactMap { item in
            try delete(item: item, in: list).wait()
        }
        return worker.newSucceededFuture(result: result)
    }

    func future<T>(_ value: T) -> EventLoopFuture<T> {
        return worker.newSucceededFuture(result: value)
    }

    func future<T>(error: Error) -> EventLoopFuture<T> {
        return worker.newFailedFuture(error: error)
    }

}
