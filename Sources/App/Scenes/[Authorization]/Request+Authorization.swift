import Vapor

extension Request {

    func checkAccess<V: Viewable>(
        for viewable: V,
        owner: User,
        user: User?
    ) throws {
        switch viewable.visibility {
        case .´private´:
            guard let user = user else {
                throw AuthorizationError.authenticationRequired
            }
            guard user.id == owner.id else {
                throw AuthorizationError.accessibleForOwnerOnly
            }
        case .´public´:
            break
        case .users:
            guard user != nil else {
                throw AuthorizationError.authenticationRequired
            }
        case .friends:
            guard let user = user else {
                throw AuthorizationError.authenticationRequired
            }
            guard user.id == owner.id else {
                throw AuthorizationError.accessibleForFriendsOnly
            }
        }
        return
    }

}
