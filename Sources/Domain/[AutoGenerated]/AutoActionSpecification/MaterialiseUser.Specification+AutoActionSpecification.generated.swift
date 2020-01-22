// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation

// MARK: MaterialiseUser.Specification

extension MaterialiseUser.Specification {

    public static func specification(
          options: MaterialiseUser.Options,
          userIdentity useridentity: UserIdentity,
          userIdentityProvider useridentityprovider: UserIdentityProvider,
          userValues uservalues: PartialValues<UserValues>,
          invitationCode invitationcode: InvitationCode?,
          guestIdentification guestidentification: Identification?
    ) -> Self {
        return Self(
            options: options,
            userIdentity: useridentity,
            userIdentityProvider: useridentityprovider,
            userValues: uservalues,
            invitationCode: invitationcode,
            guestIdentification: guestidentification
        )
    }

}
