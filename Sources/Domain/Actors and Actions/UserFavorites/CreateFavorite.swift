import Foundation
import NIO

// MARK: CreateFavorite

public struct CreateFavorite: Action {

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
                                    .logMessage(.createFavorite(for: user), using: logging)
                                    .recordEvent(.createFavorite(for: user), using: recording)
                                    .map { _ in
                                        .init(user, list)
                                    }
                            }
                    }
            }
    }

}

// MARK: Logging

extension LoggingMessageRoot {

    fileprivate static func createFavorite(for user: User) -> LoggingMessageRoot<Favorite> {
        return .init({ favorite in
            LoggingMessage(label: "Create Favorite", subject: favorite, loggables: [user])
        })
    }

}

// MARK: Recording

extension RecordingEventRoot {

    fileprivate static func createFavorite(for user: User) -> RecordingEventRoot<Favorite> {
        return .init({ favorite in
            RecordingEvent(.CREATEENTITY, subject: favorite, attributes: ["user": user])
        })
    }

}
