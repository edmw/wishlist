import Vapor
import Fluent
import FluentMySQL

final class MySQLInvitationRepository: InvitationRepository, MySQLModelRepository {
    // swiftlint:disable first_where

    let db: MySQLDatabase.ConnectionPool

    init(_ db: MySQLDatabase.ConnectionPool) {
        self.db = db
    }

    func find(by id: Invitation.ID) -> EventLoopFuture<Invitation?> {
        return db.withConnection { connection in
            return Invitation.find(id, on: connection)
        }
    }

    func find(by code: InvitationCode) -> EventLoopFuture<Invitation?> {
        return db.withConnection { connection in
            return Invitation.query(on: connection).filter(\.code == code).first()
        }
    }

    func find(by code: InvitationCode, status: Invitation.Status) -> EventLoopFuture<Invitation?> {
        return db.withConnection { connection in
            return Invitation
                .query(on: connection)
                .filter(\.code == code)
                .filter(\.status == status)
                .first()
        }
    }

    func all(for user: User) throws -> EventLoopFuture<[Invitation]> {
        let id = try user.requireID()
        return db.withConnection { connection in
            return Invitation.query(on: connection).filter(\.userID == id).all()
        }
    }

    func count(for user: User) throws -> EventLoopFuture<Int> {
        let id = try user.requireID()
        return db.withConnection { connection in
            return Invitation.query(on: connection).filter(\.userID == id).count()
        }
    }

    func count(for code: InvitationCode) throws -> EventLoopFuture<Int> {
        return db.withConnection { connection in
            return Invitation.query(on: connection).filter(\.code == code).count()
        }
    }

    func save(invitation: Invitation) -> EventLoopFuture<Invitation> {
        return db.withConnection { connection in
            if invitation.id == nil {
                // invitation create
                return Invitation.query(on: connection)
                    .filter(\.userID == invitation.userID)
                    .count()
                    .flatMap { count in
                        let maximum = Invitation.maximumNumberOfInvitationsPerUser
                        guard count < maximum else {
                            throw EntityError<Invitation>.limitReached(maximum: maximum)
                        }
                        return invitation.save(on: connection)
                    }
            }
            else {
                // invitation update
                return invitation.save(on: connection)
            }
        }
    }

    // MARK: Service

    static let serviceSupports: [Any.Type] = [InvitationRepository.self]

    static func makeService(for worker: Container) throws -> Self {
        return .init(try worker.connectionPool(to: .mysql))
    }

}
