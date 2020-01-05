import Domain

import Vapor

extension Session {

    func initialize(with user: UserRepresentation) {
        self["__user_language"] = user.language
    }

    var languageForUser: String? {
        return self["__user_language"]
    }

}
