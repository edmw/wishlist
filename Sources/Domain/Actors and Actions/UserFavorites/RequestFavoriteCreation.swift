import Foundation
import NIO

// MARK: RequestFavoriteCreation

public struct RequestFavoriteCreation: Action {

    // MARK: Boundaries

    public struct Boundaries: ActionBoundaries {
        public let worker: EventLoop
        public static func boundaries(worker: EventLoop) -> Self {
            return Self(worker: worker)
        }
    }

    // MARK: Specification

    public struct Specification: ActionSpecification {
        public let userID: UserID
        public let listID: ListID
        public static func specification(userBy userid: UserID, listBy listid: ListID) -> Self {
            return Self(userID: userid, listID: listid)
        }
    }

    // MARK: Result

    public struct Result: ActionResult {
        public let user: UserRepresentation
        public let list: ListRepresentation
        internal init(_ user: User, _ list: List) {
            self.user = user.representation
            self.list = list.representation
        }
    }

}

// MARK: - Actor

extension DomainUserFavoritesActor {

    // MARK: requestFavoriteCreation

    public func requestFavoriteCreation(
        _ specification: RequestFavoriteCreation.Specification,
        _ boundaries: RequestFavoriteCreation.Boundaries
    ) throws -> EventLoopFuture<RequestFavoriteCreation.Result> {
        let listRepository = self.listRepository
        return userRepository.find(id: specification.userID)
            .unwrap(or: UserFavoritesActorError.invalidUser)
            .flatMap { user in
                return listRepository.find(by: specification.listID)
                    .unwrap(or: UserFavoritesActorError.invalidList)
                    .flatMap { list in
                        // a user can only favorite a list if the user is authorized to access it
                        return try list.authorize(in: listRepository, for: user)
                            .map { _ in
                                return .init(user, list)
                            }
                    }
            }
    }

}
