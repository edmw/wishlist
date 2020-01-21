// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import DomainModel

// MARK: UpdateSettings.Specification

extension UpdateSettings.Specification {

    public static func specification(
          userBy userid: UserID,
          from values: PartialValues<UserSettings>
    ) -> Self {
        return Self(
            userID: userid,
            values: values
        )
    }

}
