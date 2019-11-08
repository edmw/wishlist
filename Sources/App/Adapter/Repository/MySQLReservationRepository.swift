import Vapor
import Fluent
import FluentMySQL

final class MySQLReservationRepository: ReservationRepository, MySQLModelRepository {
    // swiftlint:disable first_where

    let db: MySQLDatabase.ConnectionPool

    init(_ db: MySQLDatabase.ConnectionPool) {
        self.db = db
    }

    func find(by id: Reservation.ID) -> EventLoopFuture<Reservation?> {
        return db.withConnection { connection in
            return Reservation.find(id, on: connection)
        }
    }

    func find(item id: Item.ID) -> EventLoopFuture<Reservation?> {
        return db.withConnection { connection in
            return Reservation.query(on: connection).filter(\.itemID == id).first()
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

    // MARK: Service

    static let serviceSupports: [Any.Type] = [ReservationRepository.self]

    static func makeService(for worker: Container) throws -> Self {
        return .init(try worker.connectionPool(to: .mysql))
    }

}
