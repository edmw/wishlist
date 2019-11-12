import Foundation

struct ListPageContext: Encodable {

    var userID: ID?

    var list: ListContext?

    var form: ListPageFormContext

    init(
        for user: User,
        with list: List? = nil,
        from data: ListPageFormData? = nil
    ) {
        self.userID = ID(user.id)

        if let list = list {
            self.list = ListContext(for: list)
        }
        else {
            self.list = nil
        }

        self.form = ListPageFormContext(from: data)
    }

}

// MARK: - Builder

enum ListsPageContextBuilderError: Error {
    case missingRequiredUser
}

class ListsPageContextBuilder {

    var user: User?

    var listContexts: [ListContext]?

    @discardableResult
    func forUser(_ user: User) -> Self {
        self.user = user
        return self
    }

    @discardableResult
    func withListContexts(_ listContexts: [ListContext]?) -> Self {
        self.listContexts = listContexts
        return self
    }

    func build() throws -> ListsPageContext {
        guard let user = user else {
            throw ListsPageContextBuilderError.missingRequiredUser
        }
        return ListsPageContext(
            for: user,
            with: listContexts
        )
    }

}
