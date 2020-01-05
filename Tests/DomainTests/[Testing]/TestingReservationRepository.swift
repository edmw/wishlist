@testable import Domain
import Foundation
import NIO

final class TestingReservationRepository: ReservationRepository {

    let worker: EventLoop

    init(worker: EventLoop) {
        self.worker = worker
    }

    private var storage = [ReservationID: Reservation]()

    func find(by id: ReservationID) -> EventLoopFuture<Reservation?> {
        let result = storage[id]
        return worker.newSucceededFuture(result: result)
    }

    func find(for item: Item) throws -> EventLoopFuture<Reservation?> {
        let result = storage.values.first { $0.itemID == item.id }
        return worker.newSucceededFuture(result: result)
    }

    func findWithItem(by id: ReservationID) throws -> EventLoopFuture<(Reservation, Item)?> {
        fatalError("not implemented yet")
    }

    func all(for holder: Identification) -> EventLoopFuture<[Reservation]> {
        let result = Array(storage.values.filter { $0.holder == holder })
        return worker.newSucceededFuture(result: result)
    }

    func save(reservation: Reservation) -> EventLoopFuture<Reservation> {
        if let id = reservation.reservationID {
            storage[id] = reservation
        }
        else {
            reservation.id = UUID()
            storage[reservation.reservationID!] = reservation
        }
        return worker.newSucceededFuture(result: reservation)
    }

    func delete(reservation: Reservation, for item: Item) throws -> EventLoopFuture<Reservation?> {
        guard let reservationid = reservation.reservationID else {
            throw EntityError<Reservation>.requiredIDMissing
        }
        guard let itemid = item.itemID, itemid == reservation.itemID else {
            return worker.newSucceededFuture(result: nil)
        }
        storage.removeValue(forKey: reservationid)
        return worker.newSucceededFuture(result: reservation.detached())
    }

    func transfer(from source: Identification, to target: Identification) -> EventLoopFuture<Void> {
        fatalError("not implemented yet")
    }

    func future<T>(_ value: T) -> EventLoopFuture<T> {
        return worker.newSucceededFuture(result: value)
    }

    func future<T>(error: Error) -> EventLoopFuture<T> {
        return worker.newFailedFuture(error: error)
    }


}
