import Vapor

import Fluent
import FluentMySQL

import Foundation

protocol ReservationRepository: ModelRepository {

    func find(by id: Reservation.ID) -> Future<Reservation?>
    func find(item id: Item.ID) -> Future<Reservation?>

    func all(for holder: Identification) -> Future<[Reservation]>

    func save(reservation: Reservation) -> Future<Reservation>

    func transfer(from source: Identification, to target: Identification) -> Future<Void>

}

final class MySQLReservationRepository: ReservationRepository, MySQLModelRepository {
    // swiftlint:disable first_where

    let db: MySQLDatabase.ConnectionPool

    init(_ db: MySQLDatabase.ConnectionPool) {
        self.db = db
    }

    func find(by id: Reservation.ID) -> Future<Reservation?> {
        return db.withConnection { connection in
            return Reservation.find(id, on: connection)
        }
    }

    func find(item id: Item.ID) -> Future<Reservation?> {
        return db.withConnection { connection in
            return Reservation.query(on: connection).filter(\.itemID == id).first()
        }
    }

    func all(for holder: Identification) -> Future<[Reservation]> {
        return db.withConnection { connection in
            return Reservation.query(on: connection).filter(\.holder == holder).all()
        }
    }

    func save(reservation: Reservation) -> Future<Reservation> {
        return db.withConnection { connection in
            return reservation.save(on: connection)
        }
    }

    func transfer(from source: Identification, to target: Identification) -> Future<Void> {
        return db.withConnection { connection in
            return self.all(for: source).flatMap { reservations in
                let updates = reservations
                    .map { reservation -> Future<Reservation> in
                        reservation.holder = target
                        return reservation.update(on: connection)
                    }
                return Future.andAll(updates, eventLoop: connection.eventLoop)
            }
        }
    }

    // MARK: Service

    static let serviceSupports: [Any.Type] = [ReservationRepository.self]

    static func makeService(for worker: Container) throws -> Self {
        return .init(try worker.connectionPool(to: .mysql))
    }

}
