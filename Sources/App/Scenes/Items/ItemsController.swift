import Vapor
import Fluent

final class ItemsController: ProtectedController,
    ListParameterAcceptor,
    SortingController,
    RouteCollection
{
    typealias Sorting = ItemsSorting

    let itemRepository: ItemRepository
    let listRepository: ListRepository

    init(_ itemRepository: ItemRepository, _ listRepository: ListRepository) {
        self.itemRepository = itemRepository
        self.listRepository = listRepository
    }

    // MARK: - VIEWS

    private func renderView(on request: Request) throws -> EventLoopFuture<View> {
        let user = try requireAuthenticatedUser(on: request)

        let sorting = getSorting(on: request) ?? .ascending(by: \Item.title)
        return try requireList(on: request, for: user).flatMap { list in
            let itemContextsBuilder = ItemContextsBuilder(self.itemRepository)
                .forList(list)
                .withSorting(list.itemsSorting ?? sorting)
            return try itemContextsBuilder.build(on: request)
                .flatMap { itemContexts in
                    let context = try ItemsPageContextBuilder()
                        .forUser(user)
                        .forList(list)
                        .withItemContexts(itemContexts)
                        .build()
                    return try Controller.renderView("User/Items", with: context, on: request)
                }
        }
    }

    // MARK: -

    func boot(router: Router) throws {
        router.get("user", ID.parameter, "list", ID.parameter, "items",
            use: self.renderView
        )
    }

}
