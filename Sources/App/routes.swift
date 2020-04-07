///////////////////////////////////////////////////////////////////////////////////////////////////
// Wishlist - routes
//
// Copyright (c) 2019-2020 Michael Baumgärtner
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

import Domain

import Vapor
import Routing
import Imperial

// swiftlint:disable function_body_length

func routes(
    _ router: Router,
    _ container: Container,
    _ features: Features,
    logger: BasicLogger? = nil
) throws {

    // user routes

    let user = router.grouped(
        UserID.authSessionsMiddleware(),
        CachingHeadersMiddleware.noCachingMiddleware()
    )

    let userWelcomeActor = try container.make(UserWelcomeActor.self)
    try user.register(collection: WelcomeController(userWelcomeActor))

    try user.register(collection: LoginController())
    try user.register(collection: LogoutController())
    let userProfileActor = try container.make(UserProfileActor.self)
    try user.register(collection: ProfileController(userProfileActor))
    let userSettingsActor = try container.make(UserSettingsActor.self)
    try user.register(collection: SettingsController(userSettingsActor))
    let userNotificationsActor = try container.make(UserNotificationsActor.self)
    try user.register(collection: NotificationsController(userNotificationsActor))

    let userListsActor = try container.make(UserListsActor.self)
    try user.register(collection: ListsController(userListsActor))
    try user.register(collection: ListController(userListsActor))
    try user.register(collection: ListsImportController(userListsActor))

    let userItemsActor = try container.make(UserItemsActor.self)
    try user.register(collection: ItemsController(userItemsActor))
    try user.register(collection: ItemController(userItemsActor))

    let userFavoritesActor = try container.make(UserFavoritesActor.self)
    try user.register(collection: FavoritesController(userFavoritesActor))
    try user.register(collection: FavoriteController(userFavoritesActor))
    try user.register(collection: FavoriteNotificationController(userFavoritesActor))

    let userInvitationsActor = try container.make(UserInvitationsActor.self)
    try user.register(collection: InvitationsController(userInvitationsActor))
    try user.register(collection: InvitationController(userInvitationsActor))

    let userReservationsActor = try container.make(UserReservationsActor.self)
    try user.register(collection: ReservationController(userReservationsActor))

    // protected routes

    let protectedRoutes = router.grouped(
        UserID.authSessionsMiddleware(),
        CachingHeadersMiddleware.noCachingMiddleware()
    )

    let wishlistActor = try container.make(WishlistActor.self)
    try protectedRoutes.register(collection: WishlistController(wishlistActor))

    // public routes

    let publicRoutes = router.grouped(
        UserID.authSessionsMiddleware(),
        CachingHeadersMiddleware.noCachingMiddleware()
    )

    let announcementsActor = try container.make(AnnouncementsActor.self)
    try publicRoutes.register(collection: LegalNoticeController(announcementsActor))
    try publicRoutes.register(collection: PrivacyPolicyController(announcementsActor))

    // services routes

    let services = router.grouped(
        CachingHeadersMiddleware.noCachingMiddleware()
    )
    let googleAuthenticatorController = GoogleAuthenticatorController(
        try container.make(EnrollmentActor.self),
        authenticationSuccessPath: "/",
        authenticationErrorPath: "/authentication-error"
    )
    try services.register(collection: googleAuthenticatorController)
    let netIDAuthenticatorController = NetIDAuthenticatorController(
        try container.make(EnrollmentActor.self),
        authenticationSuccessPath: "/",
        authenticationErrorPath: "/authentication-error"
    )
    try services.register(collection: netIDAuthenticatorController)

    // error routes

    let errors = router.grouped(
        CachingHeadersMiddleware.noCachingMiddleware()
    )
    errors.get("authentication-error") { request in
        return try request.view().render("Errors/Authentication")
    }

}
