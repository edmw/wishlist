@testable import Domain
import Foundation
import NIO

import XCTest

final class WishlistActorTests : ActorTestCase, HasAllTests {

    static var __allTests = [
        ("testPresentWishlist", testPresentWishlist),
        ("testPresentWishlistWithItems", testPresentWishlistWithItems),
        ("testPresentWishlistPrivate", testPresentWishlistPrivate),
        ("testAllTests", testAllTests)
    ]

    var useridentity: UserIdentity!
    var useridentityprovider: UserIdentityProvider!
    var uservalues: UserValues!
    var partialuservalues: PartialValues<UserValues>!

    var aUser: User!

    var actor: WishlistActor!

    override func setUp() {
        super.setUp()

        aUser = try! userRepository.save(user: UserSupport.randomUser()).wait()

        actor = DomainWishlistActor(
            listRepository: listRepository,
            itemRepository: itemRepository,
            reservationRepository: reservationRepository,
            favoriteRepository: favoriteRepository,
            userRepository: userRepository,
            logging: logging,
            recording: recording
        )
    }

    func testPresentWishlist() throws {
        let aList = try! listRepository.save(
            list: List(title: "a list", visibility: .´public´, user: aUser)
        ).wait()
        let result = try! actor.presentWishlist(
            .specification(aList.id!, for: Identification(), userBy: nil),
            .boundaries(worker: eventLoop)
        ).wait()
        XCTAssertEqual(result.list, ListRepresentation(aList))
        XCTAssertEqual(result.items.count, 0)
        XCTAssertEqual(result.owner, UserRepresentation(aUser))
        XCTAssertNil(result.user)
    }

    func testPresentWishlistWithItems() throws {
        let aList = try! listRepository.save(
            list: List(title: "a list", visibility: .´public´, user: aUser)
        ).wait()
        let anItem = try! itemRepository.save(
            item: Item(title: "an item", text: "with text", list: aList)
        ).wait()
        let result = try! actor.presentWishlist(
            .specification(aList.id!, for: Identification(), userBy: nil),
            .boundaries(worker: eventLoop)
        ).wait()
        XCTAssertEqual(result.list, ListRepresentation(aList))
        XCTAssertEqual(result.items.count, 1)
        XCTAssertEqual(result.items[0], ItemRepresentation(anItem))
        XCTAssertEqual(result.owner, UserRepresentation(aUser))
        XCTAssertNil(result.user)
    }

    func testPresentWishlistPrivate() throws {
        let aList = try! listRepository.save(
            list: List(title: "a list", visibility: .´private´, user: aUser)
        ).wait()
        assert(
            try actor.presentWishlist(
                .specification(aList.id!, for: aUser!.identification, userBy: nil),
                .boundaries(worker: eventLoop)
            ).wait(),
            throws: AuthorizationError.authenticationRequired
        )
        let result = try! actor.presentWishlist(
            .specification(aList.id!, for: aUser!.identification, userBy: aUser!.id),
            .boundaries(worker: eventLoop)
        ).wait()
        XCTAssertEqual(result.list, ListRepresentation(aList))
    }

    func testAllTests() throws {
        assertAllTests()
    }

}
