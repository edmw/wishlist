// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation

// MARK: GetItems.Specification

extension GetItems.Specification {

    public static func specification(
          userBy userid: UserID,
          listBy listid: ListID,
          with sorting: ItemsSorting
    ) -> Self {
        return Self(
            userID: userid,
            listID: listid,
            sorting: sorting
        )
    }

}
