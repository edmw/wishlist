import Domain

import Foundation

struct ListsPageContext: Encodable {

    var userID: ID?

    var userName: String

    var maximumNumberOfLists: Int

    var lists: [ListContext]?

    fileprivate init(
        for user: UserRepresentation,
        with lists: [ListRepresentation]? = nil
    ) {
        self.userID = ID(user.id)

        self.userName = user.firstName

        self.maximumNumberOfLists = List.maximumNumberOfListsPerUser

        self.lists = lists?.map { list in ListContext(list) }
    }

}

// MARK: - Builder

enum ListsPageContextBuilderError: Error {
    case missingRequiredUser
}

class ListsPageContextBuilder {

    var user: UserRepresentation?

    var lists: [ListRepresentation]?

    @discardableResult
    func forUserRepresentation(_ user: UserRepresentation) -> Self {
        self.user = user
        return self
    }

    @discardableResult
    func withListRepresentations(_ lists: [ListRepresentation]?) -> Self {
        self.lists = lists
        return self
    }

    func build() throws -> ListsPageContext {
        guard let user = user else {
            throw ListsPageContextBuilderError.missingRequiredUser
        }
        return .init(for: user, with: lists)
    }

}
