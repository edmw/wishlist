// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation

// MARK: CreateList.Specification

extension CreateList.Specification {

    public static func specification(
          userBy userid: UserID,
          from values: ListValues
    ) -> Self {
        return Self(
            userID: userid,
            values: values
        )
    }

}
