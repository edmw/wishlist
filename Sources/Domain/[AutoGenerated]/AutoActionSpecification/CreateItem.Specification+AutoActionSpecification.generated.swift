// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// MARK: CreateItem.Specification

extension CreateItem.Specification {

    public static func specification(
          userBy userid: UserID,
          listBy listid: ListID,
          from values: ItemValues
    ) -> Self {
        return Self(
            userID: userid,
            listID: listid,
            values: values
        )
    }

}
