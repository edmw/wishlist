import Foundation
import NIO

// MARK: RequestFavoriteCreation

public struct RequestFavoriteCreation: Action {

    // MARK: Boundaries

    public struct Boundaries: AutoActionBoundaries {
        public let worker: EventLoop
    }

    // MARK: Specification

    public struct Specification: AutoActionSpecification {
        public let userID: UserID
        public let listID: ListID
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
