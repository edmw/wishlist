import NIO

// MARK: ReservationRepository

public protocol ReservationRepository: EntityRepository {

    func find(by id: ReservationID) -> EventLoopFuture<Reservation?>
    func find(for item: Item) throws -> EventLoopFuture<Reservation?>

    func findWithItem(by id: ReservationID)
        throws -> EventLoopFuture<(Reservation, Item)?>

    func all(for holder: Identification) -> EventLoopFuture<[Reservation]>

    func save(reservation: Reservation) -> EventLoopFuture<Reservation>

    func delete(reservation: Reservation, for item: Item) throws -> EventLoopFuture<Reservation?>

    func transfer(from source: Identification, to target: Identification) -> EventLoopFuture<Void>

}
