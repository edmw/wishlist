import Domain

import Vapor

// MARK: ItemParameterAcceptor

protocol ItemParameterAcceptor {

    func itemID(on request: Request) throws -> ItemID?

    func requireItemID(on request: Request) throws -> ItemID

    func findItemID(from request: Request) throws -> EventLoopFuture<ItemID>

}

extension ItemParameterAcceptor where Self: Controller {

    /// Returns the item id given in the request’s route or nil if there is none.
    /// Asumes that the item id is the next routing parameter!
    /// - Parameter request: the request containing the route
    func itemID(on request: Request) throws -> ItemID? {
        guard request.parameters.values.isNotEmpty else {
            return nil
        }
        return try ItemID(request.parameters.next(ID.self))
    }

    /// Returns the item id given in the request’s route. Throws if there is none.
    /// Asumes that the item id is the next routing parameter!
    /// - Parameter request: the request containing the route
    func requireItemID(on request: Request) throws -> ItemID {
        return try ItemID(request.parameters.next(ID.self))
    }

    /// Searches a item id in the request’s content and the request’s query.
    /// - Parameter request: the request
    func findItemID(from request: Request) throws -> EventLoopFuture<ItemID> {
        return request.content[ID.self, at: "itemID"]
            .map { id in
                guard let id = id ?? request.query[.itemID] else {
                    throw Abort(.notFound)
                }
                return ItemID(id)
            }
    }

}
