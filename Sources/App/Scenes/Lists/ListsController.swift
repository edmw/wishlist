import Vapor
import Fluent

final class ListsController: ProtectedController, SortingController, RouteCollection {
    typealias Sorting = ListsSorting

    // MARK: - VIEWS

    private static func renderView(on request: Request) throws -> EventLoopFuture<View> {
        let user = try requireAuthenticatedUser(on: request)

        let sorting = getSorting(on: request) ?? .ascending(by: \List.title)
        let listContextsBuilder = ListContextsBuilder()
            .forUser(user)
            .withSorting(sorting)
            .includeItemsCount(true)
        return try listContextsBuilder.build(on: request)
            .flatMap {
                let context = ListsPageContext(for: user, with: $0)
                return try renderView("User/Lists", with: context, on: request)
            }
    }

    // MARK: -

    func boot(router: Router) throws {
        router.get("user", ID.parameter, "lists",
            use: ListsController.renderView
        )
    }

}
