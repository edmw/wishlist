// MARK: Entity+Confidental

extension Entity where Self: Confidental {

    /// Authorizes access to this confidental entity.
    ///
    /// A confidental entity needing authorization is only accessible if by an entitled user.
    /// - Parameter user:
    func authorize(for user: User, owner: User) throws
        -> Authorization<Self>
    {
        guard user.id == owner.id else {
            throw AuthorizationError.accessibleForOwnerOnly
        }
        guard user.confidant else {
            throw AuthorizationError.accessibleForConfidantsOnly
        }
        return Authorization(entity: self, owner: owner, subject: user)
    }

}
