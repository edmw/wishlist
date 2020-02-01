import Domain

protocol Driver {
}

extension DomainAnnouncementsActor: Driver {}
extension DomainEnrollmentActor: Driver {}
extension DomainUserFavoritesActor: Driver {}
extension DomainUserInvitationsActor: Driver {}
extension DomainUserItemsActor: Driver {}
extension DomainUserListsActor: Driver {}
extension DomainUserNotificationsActor: Driver {}
extension DomainUserProfileActor: Driver {}
extension DomainUserReservationsActor: Driver {}
extension DomainUserSettingsActor: Driver {}
extension DomainUserWelcomeActor: Driver {}
extension DomainWishlistActor: Driver {}
