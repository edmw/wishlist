import Vapor
import Fluent

final class ItemsController: ProtectedController, SortingController, RouteCollection {
    typealias Sorting = ItemsSorting

    // MARK: - VIEWS

    private static func renderView(on request: Request) throws -> Future<View> {
        let user = try requireAuthenticatedUser(on: request)

        let sorting = getSorting(on: request) ?? .ascending(by: \Item.title)
        return try requireList(on: request, for: user)
            .flatMap { list in
                return try request.make(ItemRepository.self)
                    .allAndReservations(for: list, sort: list.itemsSorting ?? sorting)
                    .flatMap(to: View.self, { items in
                        let context = ItemsPageContext(
                            for: user,
                            and: list,
                            with: items.map { item, reservation in
                                return ItemContext(for: item, with: reservation)
                            }
                        )
                        return try renderView("User/Items", with: context, on: request)
                    }
                )
            }
    }

    // MARK: -

    func boot(router: Router) throws {
        router.get("user", ID.parameter, "list", ID.parameter, "items",
            use: ItemsController.renderView
        )
    }

}
