// sourcery:inline:WishlistPageContextBuilder.AutoPageContextBuilder

// MARK: DO NOT EDIT

import Domain

import Foundation

// MARK: WishlistPageContext

extension WishlistPageContext {

    static var builder: WishlistPageContextBuilder {
        return WishlistPageContextBuilder()
    }

}

enum WishlistPageContextBuilderError: Error {
  case missingRequiredList
  case missingRequiredOwner
  case missingRequiredIsFavorite
  case missingRequiredIdentification
}

class WishlistPageContextBuilder {

    var actions = PageActions()

    var list: ListRepresentation?
    var owner: UserRepresentation?
    var items: [ItemRepresentation]?
    var user: UserRepresentation?
    var isFavorite: Bool = false
    var identification: Identification?

    @discardableResult
    func forList(_ list: ListRepresentation) -> Self {
        self.list = list
        return self
    }

    @discardableResult
    func forOwner(_ owner: UserRepresentation) -> Self {
        self.owner = owner
        return self
    }

    @discardableResult
    func withItems(_ items: [ItemRepresentation]?) -> Self {
        self.items = items
        return self
    }

    @discardableResult
    func withUser(_ user: UserRepresentation?) -> Self {
        self.user = user
        return self
    }

    @discardableResult
    func isFavorite(_ isFavorite: Bool) -> Self {
        self.isFavorite = isFavorite
        return self
    }

    @discardableResult
    func forIdentification(_ identification: Identification) -> Self {
        self.identification = identification
        return self
    }

    @discardableResult
    func setAction(_ key: String, _ action: PageAction) -> Self {
        self.actions[key] = action
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
        var context = WishlistPageContext(
            for: list,
            of: owner,
            with: items,
            user: user,
            isFavorite: isFavorite,
            identification: identification
        )
        context.actions = actions
        return context
    }

}
// sourcery:end
