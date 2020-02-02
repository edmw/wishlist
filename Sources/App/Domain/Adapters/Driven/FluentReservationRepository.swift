import Domain

import Vapor
import Fluent
import FluentMySQL

// MARK: FluentReservationRepository

/// Adapter for port `ReservationRepository` using MySQL database.
final class FluentReservationRepository: ReservationRepository, FluentRepository {
    // swiftlint:disable first_where

    let db: MySQLDatabase.ConnectionPool

    /// Initializes the repository for **Reservations** on the specified MySQL connection pool.
    /// - Parameter db: MySQL connection pool
    init(_ db: MySQLDatabase.ConnectionPool) {
        self.db = db
    }

    func find(by id: ReservationID) -> EventLoopFuture<Reservation?> {
        return db.withConnection { connection in
            return FluentReservation.find(id.uuid, on: connection)
                .mapToEntity()
        }
    }

    func find(for item: Item) throws -> EventLoopFuture<Reservation?> {
        return db.withConnection { connection in
            let itemkey = try item.model.requireID()
            return FluentReservation.query(on: connection)
                .filter(\.itemKey == itemkey)
                .first()
                .mapToEntity()
        }
    }

    func findWithItem(by id: ReservationID)
        throws -> EventLoopFuture<(Reservation, Item)?>
    {
        return db.withConnection { connection in
            return FluentReservation.query(on: connection)
                .join(\FluentItem.uuid, to: \FluentReservation.itemKey)
                .filter(\.uuid == id.uuid)
                .alsoDecode(FluentItem.self)
                .first()
                .mapToEntities()
        }
    }

    func all(for holder: Identification) -> EventLoopFuture<[Reservation]> {
        return db.withConnection { connection in
            return FluentReservation.query(on: connection)
                .filter(\.holder == holder)
                .all()
                .mapToEntities()
        }
    }

    func save(reservation: Reservation) -> EventLoopFuture<Reservation> {
        return db.withConnection { connection in
            return reservation.model.save(on: connection)
                .mapToEntity()
        }
    }

    func delete(reservation: Reservation, for item: Item) throws -> EventLoopFuture<Reservation?> {
        return db.withConnection { connection in
            guard let itemid = item.id, itemid == reservation.itemID else {
                return connection.future(nil)
            }
            return reservation.model.delete(on: connection)
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
                            return reservation.model.update(on: connection)
                                .mapToEntity()
                        }
                    return EventLoopFuture.andAll(updates, eventLoop: connection.eventLoop)
                }
        }
    }

}

// MARK: - EventLoopFuture

extension EventLoopFuture where Expectation == (FluentReservation, FluentItem)? {

    func mapToEntities() -> EventLoopFuture<(Reservation, Item)?> {
        return self.map { models in
            guard let models = models else {
                return nil
            }
            return (Reservation(from: models.0), Item(from: models.1))
        }
    }

}
