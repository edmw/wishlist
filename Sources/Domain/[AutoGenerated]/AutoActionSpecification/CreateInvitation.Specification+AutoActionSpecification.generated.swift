// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// MARK: CreateInvitation.Specification

extension CreateInvitation.Specification {

    public static func specification(
          userBy userid: UserID,
          from values: InvitationValues,
          sendEmail sendemail: Bool
    ) -> Self {
        return Self(
            userID: userid,
            values: values,
            sendEmail: sendemail
        )
    }

}
