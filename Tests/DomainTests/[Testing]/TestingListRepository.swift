@testable import Domain
import Foundation
import NIO

final class TestingListRepository: ListRepository {

    let worker: EventLoop

    let userRepository: UserRepository

    init(worker: EventLoop, userRepository: UserRepository) {
        self.worker = worker
        self.userRepository = userRepository
    }

    private var storage = [ListID: List]()

    func find(by id: ListID) -> EventLoopFuture<List?> {
        let result = storage[id]
        return worker.newSucceededFuture(result: result)
    }

    func find(by id: ListID, for user: User) throws -> EventLoopFuture<List?> {
        let result = storage[id]
        guard result?.userID == user.id else {
            return worker.newSucceededFuture(result: nil)
        }
        return worker.newSucceededFuture(result: result)
    }

    func find(title: Title) -> EventLoopFuture<List?> {
        let result = storage.values.filter { $0.title == title }.first
        return worker.newSucceededFuture(result: result)
    }

    func find(title: Title, for user: User) throws -> EventLoopFuture<List?> {
        let result = storage.values.filter { $0.title == title }.first
        guard result?.userID == user.id else {
            return worker.newSucceededFuture(result: nil)
        }
        return worker.newSucceededFuture(result: result)
    }

    func findAndUser(by id: ListID, for userid: UserID) throws
        -> EventLoopFuture<(List, User)?>
    {
        return find(by: id)
            .flatMap { list in
                guard let list = list, list.userID == userid else {
                    return self.worker.newSucceededFuture(result: nil)
                }
                return self.userRepository.find(id: list.userID)
                    .map { user in
                        guard let user = user else {
                            return nil
                        }
                        return (list, user)
                    }
            }
    }

    func all() -> EventLoopFuture<[List]> {
        let result = Array(storage.values)
        return worker.newSucceededFuture(result: result)
    }

    func all(for user: User) throws -> EventLoopFuture<[List]> {
        return try all(for: user, sort: sortingDefault)
    }

    func all(for user: User, sort: ListsSorting) throws -> EventLoopFuture<[List]> {
        guard let userid = user.id else {
            throw EntityError<User>.requiredIDMissing
        }
        let result = Array(storage.values).filter { $0.userID == userid }
        return worker.newSucceededFuture(result: result)
    }

    func count(for user: User) throws -> EventLoopFuture<Int> {
        guard let userid = user.id else {
            throw EntityError<User>.requiredIDMissing
        }
        let result = Array(storage.values).filter { $0.userID == userid }.count
        return worker.newSucceededFuture(result: result)
    }

    func count(title: Title, for user: User) throws -> EventLoopFuture<Int> {
        guard let userid = user.id else {
            throw EntityError<User>.requiredIDMissing
        }
        let result = Array(storage.values).filter { $0.userID == userid && $0.title == title }.count
        return worker.newSucceededFuture(result: result)
    }

    func owner(of list: List) -> EventLoopFuture<User> {
        return self.userRepository.find(id: list.userID)
            .map { user in
                guard let user = user else {
                    throw EntityError<User>.lookupFailed(for: list.userID)
                }
                return user
            }
    }

    func save(list: List) -> EventLoopFuture<List> {
        if let id = list.id {
            storage[id] = list
        }
        else {
            list.id = ListID()
            storage[list.id!] = list
        }
        return worker.newSucceededFuture(result: list)
    }

    func delete(list: List, for user: User) throws -> EventLoopFuture<List?> {
        guard let listid = list.id else {
            throw EntityError<List>.requiredIDMissing
        }
        guard let userid = user.id, userid == list.userID else {
            return worker.newSucceededFuture(result: nil)
        }
        storage.removeValue(forKey: listid)
        return worker.newSucceededFuture(result: list.detached())
    }

    func available(title: String, for user: User) throws -> EventLoopFuture<String?> {
        return worker.newSucceededFuture(result: nil)
    }

    func future<T>(_ value: T) -> EventLoopFuture<T> {
        return worker.newSucceededFuture(result: value)
    }

    func future<T>(error: Error) -> EventLoopFuture<T> {
        return worker.newFailedFuture(error: error)
    }

}
