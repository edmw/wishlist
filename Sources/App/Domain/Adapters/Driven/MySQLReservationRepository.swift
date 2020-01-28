import Domain

import Vapor
import Fluent
import FluentMySQL

// MARK: MySQLReservationRepository

/// Adapter for port `ReservationRepository` using MySQL database.
final class MySQLReservationRepository: ReservationRepository, MySQLModelRepository, AutoService {
    // swiftlint:disable first_where

    let db: MySQLDatabase.ConnectionPool

    /// Initializes the repository for **Reservations** on the specified MySQL connection pool.
    /// - Parameter db: MySQL connection pool
    init(_ db: MySQLDatabase.ConnectionPool) {
        self.db = db
    }

    func find(by id: ReservationID) -> EventLoopFuture<Reservation?> {
        return db.withConnection { connection in
            return Reservation.find(id.uuid, on: connection)
        }
    }

    func find(for item: Item) throws -> EventLoopFuture<Reservation?> {
        return db.withConnection { connection in
            let itemid = try item.requireID()
            return Reservation.query(on: connection).filter(\.itemID == itemid).first()
        }
    }

    func findWithItem(by id: ReservationID)
        throws -> EventLoopFuture<(Reservation, Item)?>
    {
        return db.withConnection { connection in
            return Reservation.query(on: connection)
                .join(\Item.id, to: \Reservation.itemID)
                .filter(\.id == id.uuid)
                .alsoDecode(Item.self)
                .first()
        }
    }

    func all(for holder: Identification) -> EventLoopFuture<[Reservation]> {
        return db.withConnection { connection in
            return Reservation.query(on: connection).filter(\.holder == holder).all()
        }
    }

    func save(reservation: Reservation) -> EventLoopFuture<Reservation> {
        return db.withConnection { connection in
            return reservation.save(on: connection)
        }
    }

    func delete(reservation: Reservation, for item: Item) throws -> EventLoopFuture<Reservation?> {
        return db.withConnection { connection in
            guard let itemid = item.itemID, itemid == reservation.itemID else {
                return connection.future(nil)
            }
            return reservation.delete(on: connection)
                .transform(to: reservation.detached())
        }
    }

    func transfer(from source: Identification, to target: Identification) -> EventLoopFuture<Void> {
        return db.withConnection { connection in
            return self.all(for: source)
                .flatMap { reservations in
                    let updates = reservations
                        .map { reservation -> EventLoopFuture<Reservation> in
                            reservation.holder = target
                            return reservation.update(on: connection)
                        }
                    return EventLoopFuture.andAll(updates, eventLoop: connection.eventLoop)
                }
        }
    }

}
