// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import DomainModel

// MARK: PresentPublicly.Specification

extension PresentPublicly.Specification {

    public static func specification(
          userBy userid: UserID?
    ) -> Self {
        return Self(
            userID: userid
        )
    }

}
