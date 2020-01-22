// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation

// MARK: UpdateProfile.Specification

extension UpdateProfile.Specification {

    public static func specification(
          userBy userid: UserID,
          from values: PartialValues<UserValues>
    ) -> Self {
        return Self(
            userID: userid,
            values: values
        )
    }

}
