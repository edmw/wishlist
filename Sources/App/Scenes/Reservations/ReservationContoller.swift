import Vapor
import Fluent

final class ReservationController: ProtectedController,
    ReservationParameterAcceptor,
    ListParameterAcceptor,
    ItemParameterAcceptor,
    RouteCollection
{
    let reservationRepository: ReservationRepository
    let listRepository: ListRepository
    let itemRepository: ItemRepository

    init(
        _ reservationRepository: ReservationRepository,
        _ listRepository: ListRepository,
        _ itemRepository: ItemRepository
    ) {
        self.reservationRepository = reservationRepository
        self.listRepository = listRepository
        self.itemRepository = itemRepository
    }

    private func allowView(
        on request: Request,
        _ render: @escaping (Identification, Item, List) throws -> EventLoopFuture<View>
    ) throws -> EventLoopFuture<View> {
        let user = try getAuthenticatedUser(on: request)

        let identification = try user?.identification ?? requireIdentification(on: request)

        return try self.requireList(on: request)
            .flatMap { list in
                // check if the found list may be accessed by the given user
                // user may be nil indicating this is a anonymous request
                return try self.requireAuthorization(on: request, for: list, user: user)
                    .flatMap { _ in
                        return try self.findItem(in: list, from: request)
                            .flatMap { item in
                                // render the view after authorization
                                return try render(identification, item, list)
                            }
                    }
                    .handleAuthorizationError(on: request)
            }
    }

    // MARK: - VIEWS

    /// Renders a view to confirm the creation of a reservation.
    private func renderCreateView(on request: Request) throws
        -> EventLoopFuture<View>
    {
        return try self.allowView(on: request) { (identification, item, list) throws in
            let context = try ReservationPageContextBuilder()
                .forIdentification(identification)
                .forItem(item)
                .forList(list)
                .build()
            return try Controller.renderView(
                "Protected/ReservationCreation",
                with: context,
                on: request
            )
        }
    }

    /// Renders a view to confirm the deletion of a reservation.
    private func renderDeleteView(on request: Request) throws
        -> EventLoopFuture<View>
    {
        return try self.allowView(on: request) { (identification, item, list) throws in
            return try self.requireReservation(on: request, for: item)
                .flatMap { reservation in
                    let context = try ReservationPageContextBuilder()
                        .forIdentification(identification)
                        .forItem(item)
                        .forList(list)
                        .withReservation(reservation)
                        .build()
                    return try Controller.renderView(
                        "Protected/ReservationDeletion",
                        with: context,
                        on: request
                    )
                }
        }
    }

    // MARK: - CRUD

    private func create(on request: Request) throws -> EventLoopFuture<Response> {
        return try self.authorizeList(on: request) { (identification, list) throws in
            return try self.save(from: request, in: list, for: identification)
                .caseSuccess { result in
                    let reservation = result.reservation
                    let item = result.item
                    return try request.future(reservation)
                        .dispatchNotification(on: request) { request, _ in
                            list.user.get(on: request).map { owner in
                                return ReservationCreateNotification(for: owner, on: item, in: list)
                            }
                        }
                        .emitEvent("created on \(item) for \(identification)", on: request)
                        .logMessage("created on \(item) for \(identification)", on: request)
                        .transform(to: self.success(for: list, on: request))
                }
                .caseFailure {
                    return Controller.redirect(
                        for: list,
                        parameters: [.value(.wishAlreadyReserved, for: .message)],
                        on: request
                    )
                }
        }
    }

    private func update(on request: Request) throws -> EventLoopFuture<Response> {
        throw Abort(.notImplemented)
    }

    private func delete(on request: Request) throws -> EventLoopFuture<Response> {
        return try self.authorizeList(on: request) { identification, list throws in
            return try self.authorizeReservation(on: request, with: identification) { reservation in
                return try request.future(reservation)
                    .deleteModel(on: request)
                    .emitEvent("deleted for \(identification)", on: request)
                    .logMessage("deleted for \(identification)", on: request)
                    .dispatchNotification(on: request) { request, reservation in
                        list.user.get(on: request)
                            .and(
                                reservation.item.get(on: request)
                            )
                            .map { owner, item in
                                return ReservationDeleteNotification(for: owner, on: item, in: list)
                            }
                    }
                    .transform(to: self.success(for: list, on: request))
            }
        }
    }

    // MARK: - RESULT

    /// Returns a sucess response on a CRUD request.
    /// Not implemented yet: REST response
    private func success(for list: List, on request: Request) -> EventLoopFuture<Response> {
        // to add real REST support, check the accept header for json and output a json response
        if let locator = request.query.getLocator(is: .local) {
            return request.eventLoop.newSucceededFuture(
                result: Controller.redirect(to: locator.locationString, on: request)
            )
        }
        else {
            return request.eventLoop.newSucceededFuture(
                result: Controller.redirect(for: list, on: request)
            )
        }
    }

    // MARK: - Routing

    private func dispatch(on request: Request) throws -> EventLoopFuture<Response> {
        return try method(of: request)
            .flatMap { method -> EventLoopFuture<Response> in
                switch method {
                case .PUT:
                    return try self.update(on: request)
                case .DELETE:
                    return try self.delete(on: request)
                default:
                    throw Abort(.methodNotAllowed)
                }
            }
    }

    func boot(router: Router) throws {

        // reservation creation

        router.get("list", ID.parameter, "reservations", "create",
            use: self.renderCreateView
        )
        router.post("list", ID.parameter, "reservations",
            use: self.create
        )

        // reservation handling

        router.get("list", ID.parameter, "reservation", ID.parameter, "delete",
            use: self.renderDeleteView
        )
        router.post("list", ID.parameter, "reservation", ID.parameter,
            use: self.dispatch
        )

    }

}
