///////////////////////////////////////////////////////////////////////////////////////////////////
// Wishlist - routes
//
// Copyright (c) 2019 Michael Baumgärtner
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
///////////////////////////////////////////////////////////////////////////////////////////////////

import Vapor
import Routing
import Imperial

// swiftlint:disable function_body_length

private let googleAuthenticatorController = GoogleAuthenticatorController(
    authenticationSuccessPath: "/",
    authenticationErrorPath: "/authentication-error"
)

private let netIDAuthenticatorController = NetIDAuthenticatorController(
    authenticationSuccessPath: "/",
    authenticationErrorPath: "/authentication-error"
)

func routes(
    _ router: Router,
    _ container: Container,
    _ features: Features,
    logger: BasicLogger? = nil
) throws {

    let userRepository = try container.make(UserRepository.self)
    let listRepository = try container.make(ListRepository.self)
    let favoriteRepository = try container.make(FavoriteRepository.self)
    let itemRepository = try container.make(ItemRepository.self)
    let invitationRepository = try container.make(InvitationRepository.self)
    let reservationRepository = try container.make(ReservationRepository.self)

    // user routes

    let user = router.grouped(
        User.authSessionsMiddleware(),
        CachingHeadersMiddleware.noCachingMiddleware()
    )

    try user.register(
        collection: WelcomeController(listRepository, favoriteRepository, itemRepository)
    )

    try user.register(collection: LoginController())
    try user.register(collection: LogoutController())
    try user.register(collection: ProfileController(userRepository, invitationRepository))
    try user.register(collection: SettingsController(userRepository))

    try user.register(collection: ListsController(listRepository, itemRepository))
    try user.register(collection: ListController(listRepository, itemRepository))

    try user.register(collection: ListsImportController(listRepository, itemRepository))

    try user.register(collection: ItemsController(itemRepository, listRepository))
    try user.register(collection: ItemController(itemRepository, listRepository))

    try user.register(collection:
        FavoritesController(favoriteRepository, itemRepository)
    )
    try user.register(collection:
        FavoriteController(favoriteRepository, itemRepository, listRepository)
    )

    try user.register(collection: InvitationsController(invitationRepository))
    try user.register(collection: InvitationController(invitationRepository))

    try user.register(collection:
        ReservationControllerForOwner(reservationRepository, listRepository, itemRepository)
    )

    // protected routes

    let protectedRoutes = router.grouped(
        User.authSessionsMiddleware(),
        CachingHeadersMiddleware.noCachingMiddleware()
    )

    try protectedRoutes.register(collection:
        WishlistController(listRepository, itemRepository, favoriteRepository)
    )
    try protectedRoutes.register(collection:
        ReservationController(reservationRepository, listRepository, itemRepository)
    )

    // public routes

    let publicRoutes = router.grouped(
        User.authSessionsMiddleware(),
        CachingHeadersMiddleware.noCachingMiddleware()
    )

    try publicRoutes.register(collection: LegalNoticeController())
    try publicRoutes.register(collection: PrivacyPolicyController())

    // services routes

    let services = router.grouped(
        CachingHeadersMiddleware.noCachingMiddleware()
    )
    try services.register(collection: googleAuthenticatorController)
    if features.signinWithNetID.enabled {
        try services.register(collection: netIDAuthenticatorController)
    }

    // error routes

    let errors = router.grouped(
        CachingHeadersMiddleware.noCachingMiddleware()
    )
    errors.get("authentication-error") { request in
        return try request.view().render("Errors/Authentication")
    }

}
