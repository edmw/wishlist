import Domain

extension ID {

    /// Maps an identification to the app id type.
    init(_ identification: Identification) {
        self.init(identification.rawValue)
    }

    /// Maps an app id to the identification type.
    init?(_ identification: Identification?) {
        self.init(identification?.rawValue)
    }

}
