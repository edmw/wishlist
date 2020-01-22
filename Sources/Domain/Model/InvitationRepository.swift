import NIO

// MARK: InvitationRepository

public protocol InvitationRepository: EntityRepository {

    func find(by id: InvitationID) -> EventLoopFuture<Invitation?>

    func find(by code: InvitationCode) -> EventLoopFuture<Invitation?>
    func find(by code: InvitationCode, status: Invitation.Status) -> EventLoopFuture<Invitation?>

    func all(for user: User) throws -> EventLoopFuture<[Invitation]>

    func count(for user: User) throws -> EventLoopFuture<Int>

    func owner(of invitation: Invitation) -> EventLoopFuture<User>

    func save(invitation: Invitation) -> EventLoopFuture<Invitation>

}
