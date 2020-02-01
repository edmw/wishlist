import Domain

import Vapor
import Fluent
import FluentMySQL

// MARK: FluentInvitationRepository

/// Adapter for port `InvitationRepository` using MySQL database.
final class FluentInvitationRepository: InvitationRepository, FluentRepository {
    // swiftlint:disable first_where

    let db: MySQLDatabase.ConnectionPool

    /// Initializes the repository for **Invitations** on the specified MySQL connection pool.
    /// - Parameter db: MySQL connection pool
    init(_ db: MySQLDatabase.ConnectionPool) {
        self.db = db
    }

    func find(by id: InvitationID) -> EventLoopFuture<Invitation?> {
        return db.withConnection { connection in
            return FluentInvitation.find(id.uuid, on: connection)
                .mapToEntity()
        }
    }

    func find(by code: InvitationCode) -> EventLoopFuture<Invitation?> {
        return db.withConnection { connection in
            return FluentInvitation.query(on: connection)
                .filter(\.code == code)
                .first()
                .mapToEntity()
        }
    }

    func find(by code: InvitationCode, status: Invitation.Status) -> EventLoopFuture<Invitation?> {
        return db.withConnection { connection in
            return FluentInvitation.query(on: connection)
                .filter(\.code == code)
                .filter(\.status == status)
                .first()
                .mapToEntity()
        }
    }

    func all(for user: User) throws -> EventLoopFuture<[Invitation]> {
        guard let userid = user.userID else {
            throw EntityError<User>.requiredIDMissing
        }
        return db.withConnection { connection in
            return FluentInvitation.query(on: connection)
                .filter(\.userID == userid.uuid)
                .all()
                .mapToEntities()
        }
    }

    func count(for user: User) throws -> EventLoopFuture<Int> {
        guard let userid = user.userID else {
            throw EntityError<User>.requiredIDMissing
        }
        return db.withConnection { connection in
            return FluentInvitation.query(on: connection)
                .filter(\.userID == userid.uuid)
                .count()
        }
    }

    func owner(of invitation: Invitation) -> EventLoopFuture<User> {
        return db.withConnection { connection in
            return invitation.model.user.get(on: connection)
                .mapToEntity()
        }
    }

    func save(invitation: Invitation) -> EventLoopFuture<Invitation> {
        return db.withConnection { connection in
            if invitation.id == nil {
                // invitation create
                let limit = Invitation.maximumNumberOfInvitationsPerUser
                return FluentInvitation.query(on: connection)
                    .filter(\.userID == invitation.userID)
                    .count()
                    .max(limit, or: EntityError<Invitation>.limitReached(maximum: limit))
                    .transform(to:
                        invitation.model.save(on: connection)
                    )
                    .mapToEntity()
            }
            else {
                // invitation update
                return invitation.model.save(on: connection)
                    .mapToEntity()
            }
        }
    }

}
