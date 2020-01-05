import Domain

import Vapor

// MARK: ListParameterAcceptor

protocol ListParameterAcceptor {

    func listID(on request: Request) throws -> ListID?

    func requireListID(on request: Request) throws -> ListID

    func findListID(from request: Request) throws -> EventLoopFuture<ListID>

}

extension ListParameterAcceptor where Self: Controller {

    /// Returns the list id given in the request’s route or nil if there is none.
    /// Asumes that the list id is the next routing parameter!
    /// - Parameter request: the request containing the route
    func listID(on request: Request) throws -> ListID? {
        guard request.parameters.values.isNotEmpty else {
            return nil
        }
        return try ListID(request.parameters.next(ID.self))
    }

    /// Returns the list id given in the request’s route. Throws if there is none.
    /// Asumes that the list id is the next routing parameter!
    /// - Parameter request: the request containing the route
    func requireListID(on request: Request) throws -> ListID {
        return try ListID(request.parameters.next(ID.self))
    }

    /// Searches a list id in the request’s content and the request’s query.
    /// - Parameter request: the request
    func findListID(from request: Request) throws -> EventLoopFuture<ListID> {
        return request.content[ID.self, at: "listID"]
            .map { id in
                guard let id = id ?? request.query[.listID] else {
                    throw Abort(.notFound)
                }
                return ListID(id)
            }
    }

}
