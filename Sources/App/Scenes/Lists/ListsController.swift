import Vapor
import Fluent

final class ListsController: ProtectedController, SortingController, RouteCollection {
    typealias Sorting = ListsSorting

    let listRepository: ListRepository
    let itemRepository: ItemRepository

    init(_ listRepository: ListRepository, _ itemRepository: ItemRepository) {
        self.listRepository = listRepository
        self.itemRepository = itemRepository
    }

    // MARK: - VIEWS

    private func renderView(on request: Request) throws -> EventLoopFuture<View> {
        let user = try requireAuthenticatedUser(on: request)

        let sorting = getSorting(on: request) ?? .ascending(by: \List.title)
        let listContextsBuilder = ListContextsBuilder(listRepository, itemRepository)
            .forUser(user)
            .withSorting(sorting)
            .includeItemsCount(true)
        return try listContextsBuilder.build(on: request)
            .flatMap { listContexts in
                let context = try ListsPageContextBuilder()
                    .forUser(user)
                    .withListContexts(listContexts)
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
