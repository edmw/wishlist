import Vapor
import Fluent

final class ListsController: ProtectedController, SortingController, RouteCollection {
    typealias Sorting = ListsSorting

    // MARK: - VIEWS

    private static func renderView(on request: Request) throws -> Future<View> {
        let user = try requireAuthenticatedUser(on: request)

        let listContextsBuilder = ListContextsBuilder()
            .forUser(user)
            .withSorting(getSorting(on: request) ?? .ascending(by: \List.title))
            .countItems(true)
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
