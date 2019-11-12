import Vapor
import Fluent

final class InvitationsController: ProtectedController,
    RouteCollection
{

    let invitationRepository: InvitationRepository

    init(_ invitationRepository: InvitationRepository) {
        self.invitationRepository = invitationRepository
    }

    // MARK: -

    func boot(router: Router) throws {
    }

}
