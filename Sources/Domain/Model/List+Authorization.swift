import Foundation
import NIO

extension List {

    /// Authorizes access to this list according to the visibility of the list.
    /// - Parameter listRepository: List repository
    /// - Parameter user: User which wants to access the list or nil for anyone
    func authorize(in listRepository: ListRepository, for user: User? = nil) throws
        -> EventLoopFuture<Authorization<List>>
    {
        return listRepository.owner(of: self).map { owner in
            // check if the list may be accessed by the given user
            // user may be nil indicating this is a anonymous request
            return try self.authorize(for: user, owner: owner)
        }
    }

}

extension EventLoopFuture where Expectation == List {

    func authorize(in listRepository: ListRepository, for user: User? = nil)
        throws -> EventLoopFuture<Authorization<List>>
    {
        self.flatMap { list in try list.authorize(in: listRepository, for: user) }
    }

}
