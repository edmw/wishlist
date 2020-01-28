import Domain

extension EmailAddress {

    /// Mapping from `EmailSpecification` to `EmailAddress`. `EmailSpecification` is the value type
    /// used in the domain layer, while `EmailAddress` is the type used in the app.
    init(specification: EmailSpecification, name: String) {
        self.init(identifier: specification.rawValue, name: name)
    }

}
