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

func routes(
    _ router: Router,
    _ features: Features,
    logger: BasicLogger? = nil
) throws {

    // user routes

    let user = router.grouped(
        User.authSessionsMiddleware(),
        CachingHeadersMiddleware.noCachingMiddleware()
    )

    try user.register(collection: WelcomeController())

    try user.register(collection: LoginController())
    try user.register(collection: LogoutController())
    try user.register(collection: ProfileController())
    if features.userSettings.enabled {
        try user.register(collection: SettingsController())
    }
    
    try user.register(collection: ListsController())
    try user.register(collection: ListsImportController())
    try user.register(collection: ListController())

    try user.register(collection: ItemsController())
    try user.register(collection: ItemController())

    try user.register(collection: FavoriteController())

    try user.register(collection: InvitationController())

    // protected routes

    let protectedRoutes = router.grouped(
        User.authSessionsMiddleware(),
        CachingHeadersMiddleware.noCachingMiddleware()
    )

    try protectedRoutes.register(collection: WishlistController())
    try protectedRoutes.register(collection: ReservationController())

    // public routes

    let publicRoutes = router.grouped(
        User.authSessionsMiddleware(),
        CachingHeadersMiddleware.noCachingMiddleware()
    )

    try publicRoutes.register(collection: AboutController())

    // services routes

    let services = router.grouped(
        CachingHeadersMiddleware.noCachingMiddleware()
    )
    try services.register(collection:
        GoogleAuthenticatorController(
            authenticationSuccessPath: "/",
            authenticationErrorPath: "/authentication-error",
            logger: logger
        )
    )

    // error routes

    let errors = router.grouped(
        CachingHeadersMiddleware.noCachingMiddleware()
    )
    errors.get("authentication-error") { request in
        return try request.view().render("Errors/Authentication")
    }

}
