import DomainModel

import Foundation
import NIO

public protocol WishlistSpecification {
    var identification: Identification { get }
    var listID: ListID { get }
    var userID: UserID? { get }
}

extension DomainWishlistActor {

    /// Authorizes access to the specified list for the given user or the given identification.
    /// - Returns: `Authorization` and the actual `Identification`
    func authorizeOnWishlist(by specification: WishlistSpecification)
        -> EventLoopFuture<(Authorization<List>, Identification)>
    {
        let listid = specification.listID
        let userid = specification.userID
        let identification = specification.identification
        let listRepository = self.listRepository
        return userRepository.findIf(id: userid)
            .flatMap { user in
                guard user == nil || identification == user?.identification else {
                    throw WishlistActorError.notAuthorized
                }
                return try listRepository.find(by: listid)
                    .unwrap(or: WishlistActorError.invalidList)
                    .authorize(in: listRepository, for: user)
                    .and(result: identification)
            }
    }

}
