import Vapor

// MARK: InvitationParameterAcceptor

protocol InvitationParameterAcceptor {

    var invitationRepository: InvitationRepository { get }

    func requireInvitation(on request: Request, status: Invitation.Status?) throws
        -> EventLoopFuture<Invitation>
}

extension InvitationParameterAcceptor where Self: Controller {

    /// Returns the invitation specified by the invitation id given in the request’s route.
    /// Asumes that the invitation id is the next routing parameter!
    /// If a status is specified requires the invitation to conform to the given status,
    /// throws `.badRequest` if status’ differ.
    func requireInvitation(on request: Request, status: Invitation.Status? = nil) throws
        -> EventLoopFuture<Invitation>
    {
        let invitationID = try request.parameters.next(ID.self)
        return invitationRepository
            .find(by: invitationID.uuid)
            .unwrap(or: Abort(.noContent))
            .map { invitation in
                guard status == nil || invitation.status == status else {
                    throw Abort(.badRequest)
                }
                return invitation
            }
    }

}
