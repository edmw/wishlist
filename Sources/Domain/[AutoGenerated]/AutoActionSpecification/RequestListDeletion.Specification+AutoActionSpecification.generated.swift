// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// MARK: RequestListDeletion.Specification

extension RequestListDeletion.Specification {

    public static func specification(
          userBy userid: UserID,
          listBy listid: ListID
    ) -> Self {
        return Self(
            userID: userid,
            listID: listid
        )
    }

}