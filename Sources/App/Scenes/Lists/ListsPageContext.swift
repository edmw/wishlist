import Foundation

struct ListsPageContext: Encodable {

    var userID: ID?

    var userName: String

    var maximumNumberOfLists: Int

    var lists: [ListContext]?

    init(for user: User, with lists: [ListContext]? = nil) {
        self.userID = ID(user.id)

        self.userName = user.firstName

        self.maximumNumberOfLists = List.maximumNumberOfListsPerUser

        self.lists = lists
    }

}
