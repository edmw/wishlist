import Domain

import Vapor
import Fluent

final class ItemsController: AuthenticatableController,
    ListParameterAcceptor,
    SortingController,
    RouteCollection
{
    typealias Sorting = ItemsSorting

    let userItemsActor: UserItemsActor

    init(_ userItemsActor: UserItemsActor) {
        self.userItemsActor = userItemsActor
    }

    // MARK: - VIEWS

    private func renderView(on request: Request) throws -> EventLoopFuture<View> {
        let userid = try requireAuthenticatedUserID(on: request)
        let listid = try requireListID(on: request)

        let sorting = getSorting(on: request)
        return try userItemsActor
            .getItems(
                .specification(userBy: userid, listBy: listid, with: sorting),
                .boundaries(worker: request.eventLoop)
            )
            .flatMap { result in
                let context = try ItemsPageContext.builder
                    .forUser(result.user)
                    .forList(result.list)
                    .withItems(result.items)
                    .build()
                return try Controller.renderView("User/Items", with: context, on: request)
            }
    }

    // MARK: -

    func boot(router: Router) throws {
        router.get("user", ID.parameter, "list", ID.parameter, "items",
            use: self.renderView
        )
    }

}
