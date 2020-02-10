@testable import Domain
import Foundation
import NIO

final class TestingFavoriteRepository: FavoriteRepository {

    let worker: EventLoop

    let listRepository: ListRepository

    init(worker: EventLoop, listRepository: ListRepository) {
        self.worker = worker
        self.listRepository = listRepository
    }

    private var storage = [FavoriteID: Favorite]()

    func find(by id: FavoriteID, for user: User) throws -> EventLoopFuture<Favorite?> {
        guard let userid = user.id else {
            throw EntityError<User>.requiredIDMissing
        }
        let result = storage[id]
        guard result?.userID == userid else {
            return worker.newSucceededFuture(result: nil)
        }
        return worker.newSucceededFuture(result: result)
    }

    func find(favorite list: List, for user: User) throws -> EventLoopFuture<Favorite?> {
        guard let listid = list.id else {
            throw EntityError<List>.requiredIDMissing
        }
        guard let userid = user.id else {
            throw EntityError<User>.requiredIDMissing
        }
        let result = Array(storage.values.filter { $0.listID == listid && $0.userID == userid })
        return worker.newSucceededFuture(result: result.first)
    }

    func favorites(for user: User) throws -> EventLoopFuture<[List]> {
        return try favorites(for: user, sort: sortingDefault)
    }

    func favorites(for user: User, sort: ListsSorting) throws -> EventLoopFuture<[List]> {
        guard let id = user.id else {
            throw EntityError<User>.requiredIDMissing
        }
        let result = try Array(storage.values.filter { $0.userID == id })
            .compactMap { try self.listRepository.find(by: $0.listID).wait() }
        return worker.newSucceededFuture(result: result)
    }

    func addFavorite(_ list: List, for user: User) throws -> EventLoopFuture<Favorite> {
        guard let listid = list.id else {
            throw EntityError<List>.requiredIDMissing
        }
        guard let userid = user.id else {
            throw EntityError<User>.requiredIDMissing
        }
        let existing = Array(storage.values.filter { $0.listID == listid && $0.userID == userid })
        if let existing = existing.first {
            return worker.newSucceededFuture(result: existing)
        }
        let favorite = Favorite(userID: userid, listID: listid)
        favorite.id = FavoriteID()
        storage[favorite.id!] = favorite
        return worker.newSucceededFuture(result: favorite)
    }

    func delete(favorite: Favorite) throws -> EventLoopFuture<Favorite> {
        guard let favoriteid = favorite.id else {
            throw EntityError<Favorite>.requiredIDMissing
        }
        storage.removeValue(forKey: favoriteid)
        return worker.newSucceededFuture(result: favorite.detached())
    }

    func future<T>(_ value: T) -> EventLoopFuture<T> {
        return worker.newSucceededFuture(result: value)
    }

    func future<T>(error: Error) -> EventLoopFuture<T> {
        return worker.newFailedFuture(error: error)
    }

}
