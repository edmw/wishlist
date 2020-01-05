import Domain

import Vapor
import Fluent
import FluentMySQL

// MARK: MySQLInvitationRepository

/// Adapter for port `InvitationRepository` using MySQL database.
final class MySQLInvitationRepository: InvitationRepository, MySQLModelRepository {
    // swiftlint:disable first_where

    let db: MySQLDatabase.ConnectionPool

    /// Initializes the repository for **Invitations** on the specified MySQL connection pool.
    /// - Parameter db: MySQL connection pool
    init(_ db: MySQLDatabase.ConnectionPool) {
        self.db = db
    }

    func find(by id: InvitationID) -> EventLoopFuture<Invitation?> {
        return db.withConnection { connection in
            return Invitation.find(id.uuid, on: connection)
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
        guard let userid = user.userID else {
            throw EntityError<User>.requiredIDMissing
        }
        return db.withConnection { connection in
            return Invitation.query(on: connection).filter(\.userID == userid.uuid).all()
        }
    }

    func count(for user: User) throws -> EventLoopFuture<Int> {
        guard let userid = user.userID else {
            throw EntityError<User>.requiredIDMissing
        }
        return db.withConnection { connection in
            return Invitation.query(on: connection).filter(\.userID == userid.uuid).count()
        }
    }

    func owner(of invitation: Invitation) -> EventLoopFuture<User> {
        return db.withConnection { connection in
            return invitation.user.get(on: connection)
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

}
