// MARK: User+Representable

extension User {

    /// Returns a representation for this model.
    var representation: UserRepresentation {
        return .init(self)
    }

}
