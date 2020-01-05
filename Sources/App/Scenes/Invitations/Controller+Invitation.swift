import Domain

import Vapor

// MARK: InvitationParameterAcceptor

protocol InvitationParameterAcceptor {

    func invitationID(on request: Request) throws -> InvitationID?

    func requireInvitationID(on request: Request) throws -> InvitationID

}

extension InvitationParameterAcceptor where Self: Controller {

    /// Returns the invitation id given in the request’s route or nil if there is none.
    /// Asumes that the invitation id is the next routing parameter!
    /// - Parameter request: the request containing the route
    func invitationID(on request: Request) throws -> InvitationID? {
        guard request.parameters.values.isNotEmpty else {
            return nil
        }
        return try InvitationID(request.parameters.next(ID.self))
    }

    /// Returns the invitation id given in the request’s route. Throws if there is none.
    /// Asumes that the invitation id is the next routing parameter!
    /// - Parameter request: the request containing the route
    func requireInvitationID(on request: Request) throws -> InvitationID {
        return try InvitationID(request.parameters.next(ID.self))
    }

}
