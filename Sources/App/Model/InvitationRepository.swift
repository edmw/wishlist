import Vapor

import Fluent
import FluentMySQL

import Foundation

protocol InvitationRepository: ModelRepository {

    func find(by id: Invitation.ID) -> Future<Invitation?>
    func find(by code: InvitationCode) -> Future<Invitation?>
    func find(by code: InvitationCode, status: Invitation.Status) -> Future<Invitation?>

    func all(for user: User) throws -> Future<[Invitation]>

    func count(for user: User) throws -> Future<Int>
    func count(for code: InvitationCode) throws -> Future<Int>

    func save(invitation: Invitation) -> Future<Invitation>

}

final class MySQLInvitationRepository: InvitationRepository, MySQLModelRepository {
    // swiftlint:disable first_where

    let db: MySQLDatabase.ConnectionPool

    init(_ db: MySQLDatabase.ConnectionPool) {
        self.db = db
    }

    func find(by id: Invitation.ID) -> Future<Invitation?> {
        return db.withConnection { connection in
            return Invitation.find(id, on: connection)
        }
    }

    func find(by code: InvitationCode) -> Future<Invitation?> {
        return db.withConnection { connection in
            return Invitation.query(on: connection).filter(\.code == code).first()
        }
    }

    func find(by code: InvitationCode, status: Invitation.Status) -> Future<Invitation?> {
        return db.withConnection { connection in
            return Invitation
                .query(on: connection)
                .filter(\.code == code)
                .filter(\.status == status)
                .first()
        }
    }

    func all(for user: User) throws -> Future<[Invitation]> {
        let id = try user.requireID()
        return db.withConnection { connection in
            return Invitation.query(on: connection).filter(\.userID == id).all()
        }
    }

    func count(for user: User) throws -> Future<Int> {
        let id = try user.requireID()
        return db.withConnection { connection in
            return Invitation.query(on: connection).filter(\.userID == id).count()
        }
    }

    func count(for code: InvitationCode) throws -> Future<Int> {
        return db.withConnection { connection in
            return Invitation.query(on: connection).filter(\.code == code).count()
        }
    }

    func save(invitation: Invitation) -> Future<Invitation> {
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
