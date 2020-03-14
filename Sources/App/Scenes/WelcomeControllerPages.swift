import Domain

import Vapor

extension Page {

    private struct Context: PageContext {
        var actions = PageActions()
    }

    static func welcome() throws -> Self {
        var context = Context()
        context.actions["google"] = .get("google", "authenticate")
        context.actions["netid"] =  .get("netid", "authenticate")
        return .init(templateName: "Public/Welcome", context: context)
    }

    static func welcome(with result: GetListsAndFavorites.Result) throws -> Self {
        return try .init(
            templateName: "User/Welcome",
            context: WelcomePageContext.builder
                .forUser(result.user)
                .withLists(result.lists)
                .withFavorites(result.favorites)
                .build()
        )
    }

}
