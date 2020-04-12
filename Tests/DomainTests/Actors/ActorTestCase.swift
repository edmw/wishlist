@testable import Domain
import Foundation
import NIO

import XCTest
import Testing

// Base class for actor tests. Prepares repositories, services and logging for testing.
class ActorTestCase : XCTestCase {

    var eventLoop: EventLoop!
    var listRepository: ListRepository!
    var itemRepository: ItemRepository!
    var reservationRepository: ReservationRepository!
    var favoriteRepository: FavoriteRepository!
    var userRepository: UserRepository!
    var invitationRepository: InvitationRepository!
    var invitationService: InvitationService!
    var notificationSendingProvider: NotificationSendingProvider!
    var logging: TestingLoggingProvider!
    var recording: TestingRecordingProvider!

    lazy var enrollmentActor = DomainEnrollmentActor(
        userRepository: userRepository,
        invitationRepository: invitationRepository,
        reservationRepository: reservationRepository,
        logging: logging,
        recording: recording
    )

    lazy var userItemsActor = DomainUserItemsActor(
        itemRepository: itemRepository,
        listRepository: listRepository,
        userRepository: userRepository,
        reservationRepository: reservationRepository,
        favoriteRepository: favoriteRepository,
        logging: logging,
        recording: recording
    )

    lazy var wishlistActor = DomainWishlistActor(
        listRepository: listRepository,
        itemRepository: itemRepository,
        reservationRepository: reservationRepository,
        favoriteRepository: favoriteRepository,
        userRepository: userRepository,
        logging: logging,
        recording: recording
    )

    override func setUp() {
        super.setUp()

        eventLoop = EmbeddedEventLoop()
        userRepository = TestingUserRepository(
            worker: eventLoop
        )
        invitationRepository = TestingInvitationRepository(
            worker: eventLoop,
            userRepository: userRepository
        )
        invitationService = InvitationService(invitationRepository)
        listRepository = TestingListRepository(
            worker: eventLoop,
            userRepository: userRepository
        )
        favoriteRepository = TestingFavoriteRepository(
            worker: eventLoop,
            listRepository: listRepository
        )
        reservationRepository = TestingReservationRepository(
            worker: eventLoop
        )
        itemRepository = TestingItemRepository(
            worker: eventLoop,
            listRepository: listRepository,
            reservationRepository: reservationRepository,
            userRepository: userRepository
        )
        notificationSendingProvider = TestingNotificationSendingProvider(worker: eventLoop)
        logging = TestingLoggingProvider()
        recording = TestingRecordingProvider()
    }

}
