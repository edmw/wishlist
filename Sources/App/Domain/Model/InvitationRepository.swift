import Vapor

import Foundation

protocol InvitationRepository: EntityRepository {

    func find(by id: Invitation.ID) -> EventLoopFuture<Invitation?>
    func find(by code: InvitationCode) -> EventLoopFuture<Invitation?>
    func find(by code: InvitationCode, status: Invitation.Status) -> EventLoopFuture<Invitation?>

    func all(for user: User) throws -> EventLoopFuture<[Invitation]>

    func count(for user: User) throws -> EventLoopFuture<Int>
    func count(for code: InvitationCode) throws -> EventLoopFuture<Int>

    func save(invitation: Invitation) -> EventLoopFuture<Invitation>

}
