import Domain

extension ID {

    /// Maps a user id to the app id type.
    init(_ identifier: UserID) {
        self.init(identifier.rawValue)
    }

    /// Maps an app id to the user id type.
    init?(_ identifier: UserID?) {
        self.init(identifier?.rawValue)
    }

    public static func == (lhs: ID, rhs: UserID) -> Bool {
        return lhs.uuid == rhs
    }

    public static func == (lhs: UserID, rhs: ID) -> Bool {
        return lhs == rhs.uuid
    }

}
