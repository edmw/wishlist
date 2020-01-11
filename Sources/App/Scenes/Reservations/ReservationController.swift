import Domain

import Vapor
import Fluent

final class ReservationController: AuthenticatableController,
    ReservationParameterAcceptor,
    ListParameterAcceptor,
    ItemParameterAcceptor,
    RouteCollection
{
    let userReservationsActor: UserReservationsActor

    init(
        _ userReservationsActor: UserReservationsActor
    ) {
        self.userReservationsActor = userReservationsActor
    }

    // MARK: - VIEWS

    /// Renders a view to confirm the deletion of a reservation.
    private func renderDeleteView(on request: Request) throws
        -> EventLoopFuture<View>
    {
        let userid = try requireAuthenticatedUserID(on: request)
        let listid = try requireListID(on: request)
        let itemid = try requireItemID(on: request)
        let reservationid = try requireReservationID(on: request)
        return try userReservationsActor
            .requestReservationDeletion(
                .specification(
                    userBy: userid,
                    itemBy: itemid,
                    listBy: listid,
                    reservationBy: reservationid
                ),
                .boundaries(worker: request.eventLoop)
            )
            .flatMap { result in
                let context = try ReservationPageContextBuilder()
                    .forIdentification(result.holder)
                    .forUserRepresentation(result.user)
                    .forItemRepresentation(result.item)
                    .forListRepresentation(result.list)
                    .withReservationRepresentation(result.reservation)
                    .build()
                return try Controller.renderView(
                    "User/ReservationDeletion",
                    with: context,
                    on: request
                )
            }
    }

    // MARK: - CRUD

    private func delete(on request: Request) throws -> EventLoopFuture<Response> {
        let userid = try requireAuthenticatedUserID(on: request)
        let listid = try requireListID(on: request)
        let itemid = try requireItemID(on: request)
        let reservationid = try requireReservationID(on: request)
        return try userReservationsActor
            .deleteReservation(
                .specification(
                    userBy: userid,
                    itemBy: itemid,
                    listBy: listid,
                    reservationBy: reservationid
                ),
                .boundaries(worker: request.eventLoop)
            )
            .map { result in
                return self.success(for: result.user, and: result.list, on: request)
            }
    }

    // MARK: - RESULT

    /// Returns a success response on a CRUD request.
    /// Not implemented yet: REST response
    private func success(
        for user: UserRepresentation,
        and list: ListRepresentation,
        on request: Request
    ) -> Response {
        // to add real REST support, check the accept header for json and output a json response
        if let locator = request.query.getLocator(is: .local) {
            return Controller.redirect(to: locator.locationString, on: request)
        }
        else {
            return Controller.redirect(for: user.id, and: list.id, to: "items", on: request)
        }
    }

    // MARK: - Routing

    private func dispatch(on request: Request) throws -> EventLoopFuture<Response> {
        return try method(of: request)
            .flatMap { method -> EventLoopFuture<Response> in
                switch method {
                case .DELETE:
                    return try self.delete(on: request)
                default:
                    throw Abort(.methodNotAllowed)
                }
            }
    }

    func boot(router: Router) throws {

        // reservation handling (for owners)

        router.get(
            "user", ID.parameter,
            "list", ID.parameter,
            "item", ID.parameter,
            "reservation", ID.parameter,
            "delete",
            use: self.renderDeleteView
        )
        router.post(
            "user", ID.parameter,
            "list", ID.parameter,
            "item", ID.parameter,
            "reservation", ID.parameter,
            use: self.dispatch
        )

    }

}
