import Vapor

// MARK: ItemParameterAcceptor

protocol ItemParameterAcceptor {

    var itemRepository: ItemRepository { get }

    func requireItem(on request: Request, for list: List) throws -> EventLoopFuture<Item>

    func findItem(in list: List, from request: Request) throws -> EventLoopFuture<Item>

}

extension ItemParameterAcceptor where Self: Controller {

    /// Returns the item specified by the item id given in the request’s route.
    /// Asumes that the item’s id is the next routing parameter!
    /// The item must part of the specified list.
    func requireItem(on request: Request, for list: List) throws -> EventLoopFuture<Item> {
        let itemID = try request.parameters.next(ID.self)
        return try itemRepository
            .find(by: itemID.uuid, in: list)
            .unwrap(or: Abort(.notFound))
    }

    /// Returns the item specified by an item id given in the request’s body or query.
    func findItem(in list: List, from request: Request) throws -> EventLoopFuture<Item> {
        return request.content[ID.self, at: "itemID"]
            .flatMap { itemID in
                guard let itemID = itemID ?? request.query[.itemID] else {
                    throw Abort(.notFound)
                }
                return try self.itemRepository
                    .find(by: itemID.uuid, in: list)
                    .unwrap(or: Abort(.noContent))
            }
    }

}
