@testable import Domain
import Foundation
import NIO

final class TestingUserRepository: UserRepository {

    let worker: EventLoop

    init(worker: EventLoop) {
        self.worker = worker
    }

    private var storage = [UserID: User]()

    func find(id: UserID) -> EventLoopFuture<User?> {
        let result = storage[id]
        return worker.newSucceededFuture(result: result)
    }

    func findIf(id: UserID?) -> EventLoopFuture<User?> {
        guard let id = id else {
            return worker.newSucceededFuture(result: nil)
        }
        return find(id: id)
    }

    func find(identification: Identification) -> EventLoopFuture<User?> {
        let result = storage.values.first { $0.identification == identification }
        return worker.newSucceededFuture(result: result)
    }

    func find(identity: UserIdentity, of provider: UserIdentityProvider) -> EventLoopFuture<User?> {
        let result
            = storage.values.first { $0.identity == identity && $0.identityProvider == provider }
        return worker.newSucceededFuture(result: result)
    }

    func find(nickName: String) -> EventLoopFuture<User?> {
        let result = storage.values.first { $0.nickName == nickName }
        return worker.newSucceededFuture(result: result)
    }

    func all() -> EventLoopFuture<[User]> {
        let result = Array(storage.values)
        return worker.newSucceededFuture(result: result)
    }

    func count() -> EventLoopFuture<Int> {
        let result = storage.count
        return worker.newSucceededFuture(result: result)
    }

    func count(nickName: String) -> EventLoopFuture<Int> {
        let result = storage.values.filter { $0.nickName == nickName }
        return worker.newSucceededFuture(result: result.count)
    }

    func save(user: User) -> EventLoopFuture<User> {
        if let id = user.userID {
            storage[id] = user
        }
        else {
            user.id = UUID()
            storage[user.userID!] = user
        }
        return worker.newSucceededFuture(result: user)
    }

    func future<T>(_ value: T) -> EventLoopFuture<T> {
        return worker.newSucceededFuture(result: value)
    }

    func future<T>(error: Error) -> EventLoopFuture<T> {
        return worker.newFailedFuture(error: error)
    }


}
