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

        let sorting = getSorting(on: request) ?? .ascending(by: \List.title)
        return try userListsActor
            .getLists(
                .specification(userBy: userid, with: sorting),
                .boundaries(worker: request.eventLoop)
            )
            .flatMap { result in
                let context = try ListsPageContextBuilder()
                    .forUser(result.user)
                    .withLists(result.lists)
                    .build()
                return try Controller.renderView("User/Lists", with: context, on: request)
            }
    }

    // MARK: -

    func boot(router: Router) throws {
        router.get("user", ID.parameter, "lists",
            use: self.renderView
        )
    }

}
