import Domain

extension ID {

    /// Maps an invitation id to the app id type.
    init(_ identifier: InvitationID) {
        self.init(identifier.rawValue)
    }

    /// Maps an invitation id to the app id type.
    init?(_ identifier: InvitationID?) {
        self.init(identifier?.rawValue)
    }

}

extension InvitationID {

    /// Maps an app id to the invitation id type.
    init(_ id: ID) {
        self.init(uuid: id.uuid)
    }

}
