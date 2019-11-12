import Vapor
import Fluent
import FluentMySQL

/// Adapter for port `InvitationRepository` using MySQL database.
final class MySQLInvitationRepository: InvitationRepository, MySQLModelRepository {
    // swiftlint:disable first_where

    let db: MySQLDatabase.ConnectionPool

    /// Initializes the repository for **Invitations** on the specified MySQL connection pool.
    /// - Parameter db: MySQL connection pool
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
                let limit = Invitation.maximumNumberOfInvitationsPerUser
                return Invitation.query(on: connection)
                    .filter(\.userID == invitation.userID)
                    .count()
                    .max(limit, or: EntityError<Invitation>.limitReached(maximum: limit))
                    .transform(to:
                        invitation.save(on: connection)
                    )
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
