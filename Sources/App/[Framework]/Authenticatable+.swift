import Vapor
import Authentication

import Domain

/// Extends `UserID` type to be used as identifiaction for a logged in user in the session.
extension UserID: SessionAuthenticatable {

    public typealias SessionID = UUID

    public var sessionID: UUID? {
        return rawValue
    }

    public static func authenticate(sessionID: UUID, on conn: DatabaseConnectable)
        -> EventLoopFuture<Self?>
    {
        return conn.future(.init(uuid: sessionID))
    }

}
