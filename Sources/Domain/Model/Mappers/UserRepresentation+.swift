import DomainModel
import Library

// MARK: UserRepresentation

extension UserRepresentation {

    internal init(_ user: User) {
        self.init(
            id: user.userID,
            nickName: user.nickName,
            displayName: user.displayName,
            fullName: user.fullName,
            firstName: user.firstName,
            lastName: user.lastName,
            email: String(user.email),
            language: user.language,
            confidant: user.confidant,
            firstLogin: user.firstLogin,
            lastLogin: user.lastLogin,
            settings: user.settings
        )
    }

}
