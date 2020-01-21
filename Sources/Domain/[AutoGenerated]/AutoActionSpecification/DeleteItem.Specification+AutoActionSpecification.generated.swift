// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import DomainModel

// MARK: DeleteItem.Specification

extension DeleteItem.Specification {

    public static func specification(
          userBy userid: UserID,
          listBy listid: ListID,
          itemBy itemid: ItemID
    ) -> Self {
        return Self(
            userID: userid,
            listID: listid,
            itemID: itemid
        )
    }

}
