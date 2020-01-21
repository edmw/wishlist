// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import DomainModel

// MARK: CreateOrUpdateList.Specification

extension CreateOrUpdateList.Specification {

    public static func specification(
          userBy userid: UserID,
          listBy listid: ListID?,
          from values: ListValues
    ) -> Self {
        return Self(
            userID: userid,
            listID: listid,
            values: values
        )
    }

}
