// MARK: Entity+Viewable

extension Entity where Self: Viewable {

    /// Authorizes access to this entity according to the visibility of the entity.
    ///
    /// A viewable entity needing authorization is only accessible if it is public, or accessed
    /// by an entitled user.
    /// - Parameter user:
    /// - Parameter owner:
    func authorize(for user: User?, owner: User) throws
        -> Authorization<Self>
    {
        switch self.visibility {
        case .users:
            // accessible for all users
            guard user != nil else {
                throw AuthorizationError.authenticationRequired
            }
        case .friends:
            // accessible for friends of the owner
            guard let user = user else {
                throw AuthorizationError.authenticationRequired
            }
            // while there is no friends system now, only accessible for the owner
            guard user.id == owner.id else {
                throw AuthorizationError.accessibleForFriendsOnly
            }
        case .´private´:
            // accessible for the owner
            guard let user = user else {
                throw AuthorizationError.authenticationRequired
            }
            guard user.id == owner.id else {
                throw AuthorizationError.accessibleForOwnerOnly
            }
        case .´public´:
            // accessible for anyone
            break
        }
        return Authorization(entity: self, owner: owner, subject: user)
    }

}
