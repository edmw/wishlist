// MARK: Entity+Confidental

extension Entity where Self: Confidental {

    /// Authorizes access to this confidental entity.
    ///
    /// A confidental entity needing authorization is only accessible by an entitled user.
    /// - Parameter user: User, which wants access to this entity.
    /// - Parameter owner: User, which owns this entity.
    func authorize(for user: User, owner: User) throws
        -> Authorization<Self>
    {
        let ownerid = self[keyPath: Self.confidantUserID]
        guard owner.id == ownerid else {
            throw AuthorizationError.authenticationRequired
        }
        guard user.id == ownerid else {
            throw AuthorizationError.accessibleForOwnerOnly
        }
        guard user.confidant else {
            throw AuthorizationError.accessibleForConfidantsOnly
        }
        return Authorization(entity: self, owner: owner, subject: user)
    }

}
