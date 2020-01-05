import Foundation
import NIO

// MARK: CreateFavorite

public struct CreateFavorite: Action {

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

    // MARK: createFavorite

    public func createFavorite(
        _ specification: CreateFavorite.Specification,
        _ boundaries: CreateFavorite.Boundaries
    ) throws -> EventLoopFuture<CreateFavorite.Result> {
        let listRepository = self.listRepository
        let favoriteRepository = self.favoriteRepository
        let logging = self.logging
        let recording = self.recording
        return userRepository.find(id: specification.userID)
            .unwrap(or: UserFavoritesActorError.invalidUser)
            .flatMap { user in
                return listRepository.find(by: specification.listID)
                    .unwrap(or: UserFavoritesActorError.invalidList)
                    .flatMap { list in
                        // a user can only favorite a list if the user is authorized to access it
                        return try list.authorize(in: listRepository, for: user)
                            .flatMap { _ in
                                return try favoriteRepository
                                    .addFavorite(list, for: user)
                                    .recordEvent("created for \(user)", using: recording)
                                    .logMessage("created for \(user)", using: logging)
                                    .map { _ in
                                        .init(user, list)
                                    }
                            }
                    }
            }
    }

}
