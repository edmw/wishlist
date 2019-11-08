import Vapor

import Foundation

protocol ReservationRepository: EntityRepository {

    func find(by id: Reservation.ID) -> EventLoopFuture<Reservation?>
    func find(item id: Item.ID) -> EventLoopFuture<Reservation?>

    func all(for holder: Identification) -> EventLoopFuture<[Reservation]>

    func save(reservation: Reservation) -> EventLoopFuture<Reservation>

    func transfer(from source: Identification, to target: Identification) -> EventLoopFuture<Void>

}
