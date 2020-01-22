// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation

// MARK: RequestInvitationRevocation.Specification

extension RequestInvitationRevocation.Specification {

    public static func specification(
          userBy userid: UserID,
          invitationBy invitationid: InvitationID
    ) -> Self {
        return Self(
            userID: userid,
            invitationID: invitationid
        )
    }

}
