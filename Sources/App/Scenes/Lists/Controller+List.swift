import Vapor

// MARK: ListParameterAcceptor

protocol ListParameterAcceptor {

    var listRepository: ListRepository { get }

    func requireList(on request: Request) throws -> EventLoopFuture<List>

    func requireList(on request: Request, for user: User) throws -> EventLoopFuture<List>

}

extension ListParameterAcceptor where Self: Controller {

    /// Returns the list specified by the list id given in the request’s route.
    /// Asumes that the list’s id is the next routing parameter!
    func requireList(on request: Request) throws -> EventLoopFuture<List> {
        let listID = try request.parameters.next(ID.self)
        return listRepository
            .find(by: listID.uuid)
            .unwrap(or: Abort(.notFound))
    }

    /// Returns the list specified by the list id given in the request’s route.
    /// Asumes that the list’s id is the next routing parameter!
    /// The list must be owned by the specified user.
    func requireList(on request: Request, for user: User) throws -> EventLoopFuture<List> {
        let listID = try request.parameters.next(ID.self)
        return try listRepository
            .find(by: listID.uuid, for: user)
            .unwrap(or: Abort(.notFound))
    }

    /// Returns the list specified by an list id given in the request’s body or query.
    func findList(from request: Request) throws -> EventLoopFuture<List> {
        return request.content[ID.self, at: "listID"]
            .flatMap { listID in
                guard let listID = listID ?? request.query[.listID] else {
                    throw Abort(.notFound)
                }
                return self.listRepository
                    .find(by: listID.uuid)
                    .unwrap(or: Abort(.noContent))
            }
    }

}
