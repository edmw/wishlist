import Domain

import Vapor
import Fluent

final class ListsController: AuthenticatableController,
    SortingController,
    RouteCollection
{
    typealias Sorting = ListsSorting

    let userListsActor: UserListsActor

    init(_ userListsActor: UserListsActor) {
        self.userListsActor = userListsActor
    }

    // MARK: - VIEWS

    private func renderView(on request: Request) throws -> EventLoopFuture<View> {
        let userid = try requireAuthenticatedUserID(on: request)

        let sorting = getSorting(on: request)
        return try userListsActor
            .getLists(
                .specification(userBy: userid, with: sorting),
                .boundaries(worker: request.eventLoop)
            )
            .flatMap { result in
                try Controller.render(page: .lists(with: result), on: request)
            }
    }

    // MARK: -

    func boot(router: Router) throws {
        router.get("user", ID.parameter, "lists",
            use: self.renderView
        )
    }

}
