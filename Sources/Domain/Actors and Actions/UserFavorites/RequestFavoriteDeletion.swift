import Foundation
import NIO

// MARK: RequestFavoriteDeletion

public struct RequestFavoriteDeletion: Action {

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

    // MARK: requestFavoriteDeletion

    public func requestFavoriteDeletion(
        _ specification: RequestFavoriteDeletion.Specification,
        _ boundaries: RequestFavoriteDeletion.Boundaries
    ) throws -> EventLoopFuture<RequestFavoriteDeletion.Result> {
        let listRepository = self.listRepository
        let favoriteRepository = self.favoriteRepository
        return userRepository.find(id: specification.userID)
            .unwrap(or: UserFavoritesActorError.invalidUser)
            .flatMap { user in
                return listRepository.find(by: specification.listID)
                    .unwrap(or: UserFavoritesActorError.invalidList)
                    .flatMap { list in
                        // list must be owned by the user
                        guard list.userID == user.id else {
                            throw UserFavoritesActorError.invalidListForUser
                        }
                        return try favoriteRepository.find(favorite: list, for: user)
                            .unwrap(or: UserFavoritesActorError.favoriteNotExisting)
                            .map { _ in
                                return .init(user, list)
                            }
                    }
            }
    }

}
