import Domain

import Foundation

struct ListsPageContext: PageContext, AutoPageContextBuilder {

    var userID: ID?

    var userName: String

    var maximumNumberOfLists: Int

    var lists: [ListContext]?

    // sourcery: AutoPageContextBuilderInitializer
    init(
        for user: UserRepresentation,
        with lists: [ListRepresentation]? = nil
    ) {
        self.userID = ID(user.id)

        self.userName = user.firstName

        self.maximumNumberOfLists = List.maximumNumberOfListsPerUser

        self.lists = lists?.map { list in ListContext(list) }
    }

}
