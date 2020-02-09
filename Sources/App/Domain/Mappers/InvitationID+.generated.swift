// sourcery:inline:InvitationID.AutoMapper

// MARK: DO NOT EDIT

import Domain

// MARK: InvitationID

extension InvitationID {

    /// Maps an app id to the invitationid type.
    init(_ id: ID) {
        self.init(uuid: id.uuid)
    }

}

extension ID {

    /// Maps a invitationid to the app id type.
    init(_ identifier: InvitationID) {
        self.init(identifier.uuid)
    }

    /// Maps an app id to the invitationid type.
    init?(_ identifier: InvitationID?) {
        self.init(identifier?.uuid)
    }

    public static func == (lhs: ID, rhs: InvitationID) -> Bool {
        return lhs.uuid == rhs
    }

    public static func == (lhs: InvitationID, rhs: ID) -> Bool {
        return lhs == rhs.uuid
    }

}
// sourcery:end
