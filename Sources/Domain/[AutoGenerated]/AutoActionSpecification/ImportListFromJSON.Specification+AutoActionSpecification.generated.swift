// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// MARK: ImportListFromJSON.Specification

extension ImportListFromJSON.Specification {

    public static func specification(
          userBy userid: UserID,
          json: String
    ) -> Self {
        return Self(
            userID: userid,
            json: json
        )
    }

}
