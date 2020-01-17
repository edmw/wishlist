// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// MARK: CreateOrUpdateItem.Specification

extension CreateOrUpdateItem.Specification {

    public static func specification(
          userBy userid: UserID,
          listBy listid: ListID,
          itemBy itemid: ItemID?,
          from values: ItemValues
    ) -> Self {
        return Self(
            userID: userid,
            listID: listid,
            itemID: itemid,
            values: values
        )
    }

}