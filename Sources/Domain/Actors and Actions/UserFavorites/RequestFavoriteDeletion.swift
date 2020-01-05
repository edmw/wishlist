import Foundation
import NIO

// MARK: RequestFavoriteDeletion

public struct RequestFavoriteDeletion: Action {

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

    // MARK: requestFavoriteDeletion

    public func requestFavoriteDeletion(
        _ specification: RequestFavoriteDeletion.Specification,
        _ boundaries: RequestFavoriteDeletion.Boundaries
    ) throws -> EventLoopFuture<RequestFavoriteDeletion.Result> {
        let listRepository = self.listRepository
        return userRepository.find(id: specification.userID)
            .unwrap(or: UserFavoritesActorError.invalidUser)
            .flatMap { user in
                return listRepository.find(by: specification.listID)
                    .unwrap(or: UserFavoritesActorError.invalidList)
                    .map { list in
                        // list must be owned by the user
                        guard list.userID == user.id else {
                            throw UserFavoritesActorError.invalidListForUser
                        }
                        return .init(user, list)
                    }
            }
    }

}
