import Domain

protocol Driven {
}

extension FluentFavoriteRepository: Driven {}
extension FluentInvitationRepository: Driven {}
extension FluentItemRepository: Driven {}
extension FluentListRepository: Driven {}
extension FluentReservationRepository: Driven {}
extension FluentUserRepository: Driven {}

extension VaporEmailSendingProvider: Driven {}
extension VaporEventRecordingProvider: Driven {}
extension VaporImageStoreProvider: Driven {}
extension VaporMessageLoggingProvider: Driven {}
extension VaporNotificationSendingProvider: Driven {}
