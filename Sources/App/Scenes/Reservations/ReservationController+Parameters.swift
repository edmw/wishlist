import Vapor

// MARK: ReservationController

extension ReservationController {

    /// Returns the reservation specified by the reservation id given in the request’s route.
    /// Asumes that the reservation’s id is the next routing parameter!
    static func requireReservation(on request: Request) throws -> EventLoopFuture<Reservation> {
        let reservationID = try request.parameters.next(ID.self)
        return try request.make(ReservationRepository.self)
            .find(by: reservationID.uuid)
            .unwrap(or: Abort(.noContent))
    }

    /// Returns the reservation specified by the reservation id given in the request’s route.
    /// Asumes that the reservation’s id is the next routing parameter!
    static func requireReservation(
        on request: Request,
        for item: Item
    ) throws -> EventLoopFuture<Reservation> {
        let reservationID = try request.parameters.next(ID.self)
        return try request.make(ReservationRepository.self)
            .find(by: reservationID.uuid)
            .unwrap(or: Abort(.noContent))
            .map { reservation in
                guard reservation.itemID == item.id else {
                    throw Abort(.noContent)
                }
                return reservation
            }
    }

    /// Returns the item specified by an item id given in the request’s body or query.
    static func findItem(in list: List, from request: Request) throws -> EventLoopFuture<Item> {
        return request.content[ID.self, at: "itemID"]
            .flatMap { itemID in
                guard let itemID = itemID ?? request.query[.itemID] else {
                    throw Abort(.notFound)
                }
                return try request.make(ItemRepository.self)
                    .find(by: itemID.uuid, in: list)
                    .unwrap(or: Abort(.noContent))
            }
    }

}
