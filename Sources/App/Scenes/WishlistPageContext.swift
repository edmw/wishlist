import Foundation

struct WishlistPageContext: Encodable {

    var ownerID: ID?
    var listID: ID?

    var ownerName: String
    var listTitle: String

    var items: [ItemContext]?

    var userID: ID?

    var userFullName: String?
    var userFirstName: String?

    var userFavorsList: Bool

    var identification: ID?

    fileprivate init(
        for list: List,
        of owner: User,
        with items: [ItemContext]? = nil,
        user: User? = nil,
        identification: Identification
    ) {
        self.ownerID = ID(owner.id)
        self.listID = ID(list.id)

        self.ownerName = owner.displayName
        self.listTitle = list.title

        self.items = items

        self.userID = ID(user?.id)

        self.userFullName = user?.fullName
        self.userFirstName = user?.firstName
        self.userFavorsList = false

        self.identification = ID(identification)
    }

}

// MARK: - Builder

enum WishlistPageContextBuilderError: Error {
    case missingRequiredList
    case missingRequiredOwner
    case missingRequiredIdentification
}

class WishlistPageContextBuilder {

    var list: List?
    var owner: User?

    var user: User?

    var items: [ItemContext]?

    var identification: Identification?

    @discardableResult
    func forList(_ list: List) -> Self {
        self.list = list
        return self
    }

    @discardableResult
    func forOwner(_ owner: User) -> Self {
        self.owner = owner
        return self
    }

    @discardableResult
    func withItems(_ items: [ItemContext]) -> Self {
        self.items = items
        return self
    }

    @discardableResult
    func withUser(_ user: User) -> Self {
        self.user = user
        return self
    }

    @discardableResult
    func forIdentification(_ identification: Identification) -> Self {
        self.identification = identification
        return self
    }

    func build() throws -> WishlistPageContext {
        guard let list = list else {
            throw WishlistPageContextBuilderError.missingRequiredList
        }
        guard let owner = owner else {
            throw WishlistPageContextBuilderError.missingRequiredOwner
        }
        guard let identification = identification else {
            throw WishlistPageContextBuilderError.missingRequiredIdentification
        }
        return WishlistPageContext(
            for: list,
            of: owner,
            with: items,
            user: user,
            identification: identification
        )
    }

}
