import Vapor
import Fluent

final class InvitationsController: ProtectedController, RouteCollection {

    static func buildContexts(for user: User, on request: Request) throws
        -> Future<[InvitationContext]>
    {
        return try request.make(InvitationRepository.self)
            .all(for: user)
            .flatMap { (invitations) throws -> Future<[InvitationContext]> in
                let contexts = try invitations.map { (invitation) throws -> InvitationContext in
                    InvitationContext(for: invitation)
                }
                return request.future(contexts)
            }
    }

    // MARK: -

    func boot(router: Router) throws {
    }

}
