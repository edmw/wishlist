// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// MARK: RevokeInvitation.Specification

extension RevokeInvitation.Specification {

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