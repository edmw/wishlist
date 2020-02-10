@testable import Domain
import Foundation
import NIO

import XCTest

class ActorTestCase : XCTestCase {

    var eventLoop: EventLoop!
    var listRepository: ListRepository!
    var itemRepository: ItemRepository!
    var reservationRepository: ReservationRepository!
    var favoriteRepository: FavoriteRepository!
    var userRepository: UserRepository!
    var invitationRepository: InvitationRepository!
    var invitationService: InvitationService!
    var logging: TestingLoggingProvider!
    var recording: TestingRecordingProvider!

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
        logging = TestingLoggingProvider()
        recording = TestingRecordingProvider()
    }

}
