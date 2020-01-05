@testable import Domain
import Foundation
import NIO

final class TestingInvitationRepository: InvitationRepository {

    let worker: EventLoop

    let userRepository: UserRepository

    init(worker: EventLoop, userRepository: UserRepository) {
        self.worker = worker
        self.userRepository = userRepository
    }

    private var storage = [InvitationID: Invitation]()

    func find(by id: InvitationID) -> EventLoopFuture<Invitation?> {
        let result = storage[id]
        return worker.newSucceededFuture(result: result)
    }

    func find(by code: InvitationCode) -> EventLoopFuture<Invitation?> {
        let result = storage.values.first { $0.code == code }
        return worker.newSucceededFuture(result: result)
    }

    func find(by code: InvitationCode, status: Invitation.Status) -> EventLoopFuture<Invitation?> {
        let result
            = storage.values.first { $0.code == code && $0.status == status }
        return worker.newSucceededFuture(result: result)
    }

    func all(for user: User) throws -> EventLoopFuture<[Invitation]> {
        guard let id = user.id else {
            throw EntityError<User>.requiredIDMissing
        }
        let result = Array(storage.values.filter { $0.userID == id })
        return worker.newSucceededFuture(result: result)
    }

    func count(for user: User) throws -> EventLoopFuture<Int> {
        guard let id = user.id else {
            throw EntityError<User>.requiredIDMissing
        }
        let result = storage.values.filter { $0.userID == id }.count
        return worker.newSucceededFuture(result: result)
    }

    func owner(of invitation: Invitation) -> EventLoopFuture<User> {
        return userRepository.find(id: UserID(uuid: invitation.userID)).map { $0! }
    }

    func save(invitation: Invitation) -> EventLoopFuture<Invitation> {
        if let id = invitation.invitationID {
            storage[id] = invitation
        }
        else {
            invitation.id = UUID()
            storage[invitation.invitationID!] = invitation
        }
        return worker.newSucceededFuture(result: invitation)
    }

    func future<T>(_ value: T) -> EventLoopFuture<T> {
        return worker.newSucceededFuture(result: value)
    }

    func future<T>(error: Error) -> EventLoopFuture<T> {
        return worker.newFailedFuture(error: error)
    }


}
