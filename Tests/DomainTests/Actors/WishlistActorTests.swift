@testable import Domain
import Foundation
import NIO

import XCTest
import Testing

final class WishlistActorTests : ActorTestCase, DomainTestCase, HasAllTests {

    static var __allTests = [
        ("testPresentWishlist", testPresentWishlist),
        ("testPresentWishlistWithItems", testPresentWishlistWithItems),
        ("testPresentWishlistPrivate", testPresentWishlistPrivate),
        ("testPresentWishlistInvalidIdentification", testPresentWishlistInvalidIdentification),
        ("testPresentWishlistNonExistingList", testPresentWishlistNonExistingList),
        ("testAddReservationToItem", testAddReservationToItem),
        ("testAllTests", testAllTests)
    ]

    var useridentity: UserIdentity!
    var useridentityprovider: UserIdentityProvider!
    var uservalues: UserValues!
    var partialuservalues: PartialValues<UserValues>!

    var aUser: User!

    override func setUp() {
        super.setUp()

        aUser = try! userRepository.save(user: User.randomUser()).wait()
    }

    /// Testing `PresentWishlist` action with a public list and anonymous access.
    /// Expects a list representation which matches the representation of the
    /// corresponding list.
    func testPresentWishlist() throws {
        let aList = try! listRepository.save(
            list: List(title: "a list", visibility: .´public´, user: aUser)
        ).wait()
        let result = try! wishlistActor.presentWishlist(
            .specification(aList.id!, for: Identification(), userBy: nil),
            .boundaries(worker: eventLoop)
        ).wait()
        XCTAssertEqual(result.list.id, aList.id)
        XCTAssertEqual(result.items.count, 0)
        XCTAssertEqual(result.owner.id, aUser.id)
        XCTAssertNil(result.user)
    }

    /// Testing `PresentWishlist` action with a public list with items and anonymous access.
    /// Expects a list representation which matches the representation of the
    /// corresponding list.
    func testPresentWishlistWithItems() throws {
        let aList = try! listRepository.save(
            list: List(title: "a list", visibility: .´public´, user: aUser)
        ).wait()
        let anItem = try! itemRepository.save(
            item: Item(title: "an item", text: "with text", list: aList)
        ).wait()
        let result = try! wishlistActor.presentWishlist(
            .specification(aList.id!, for: Identification(), userBy: nil),
            .boundaries(worker: eventLoop)
        ).wait()
        XCTAssertEqual(result.list.id, aList.id)
        XCTAssertEqual(result.items.count, 1)
        XCTAssertEqual(result.items[0].id, anItem.id)
        XCTAssertEqual(result.owner.id, aUser.id)
        XCTAssertNil(result.user)
    }

    /// Testing `PresentWishlist` action with a private list.
    /// Expects an exeception when using anonymous access and a list representation which matches
    /// the representation of the corresponding list when using the owner to access the list.
    func testPresentWishlistPrivate() throws {
        let aList = try! listRepository.save(
            list: List(title: "a list", visibility: .´private´, user: aUser)
        ).wait()
        assert(
            try wishlistActor.presentWishlist(
                .specification(aList.id!, for: aUser!.identification, userBy: nil),
                .boundaries(worker: eventLoop)
            ).wait(),
            throws: AuthorizationError.authenticationRequired
        )
        let result = try! wishlistActor.presentWishlist(
            .specification(aList.id!, for: aUser!.identification, userBy: aUser!.id),
            .boundaries(worker: eventLoop)
        ).wait()
        XCTAssertEqual(result.list.id, aList.id)
    }

    /// Testing `PresentWishlist` action with an invalid identifiction.
    /// Expects an exeception.
    func testPresentWishlistInvalidIdentification() throws {
        assert(
            try wishlistActor.presentWishlist(
                .specification(ListID(), for: Identification(), userBy: aUser!.id),
                .boundaries(worker: eventLoop)
            ).wait(),
            throws: WishlistActorError.invalidIdentification
        )
    }

    /// Testing `PresentWishlist` action with a non-existing list.
    /// Expects an exeception.
    func testPresentWishlistNonExistingList() throws {
        assert(
            try wishlistActor.presentWishlist(
                .specification(ListID(), for: aUser!.identification, userBy: nil),
                .boundaries(worker: eventLoop)
            ).wait(),
            throws: WishlistActorError.invalidList
        )
    }

    /// Testing `AddReservationToItem` action.
    func testAddReservationToItem() throws {
        let aList = try! listRepository.save(
            list: List(title: "a list", visibility: .´public´, user: aUser)
        ).wait()
        let anItem = try! itemRepository.save(
            item: Item(title: "an item", text: "with text", list: aList)
        ).wait()
        let result = try! wishlistActor.addReservationToItem(
            .specification(anItem.id!, on: aList.id!, for: aUser!.identification, userBy: nil),
            .boundaries(worker: eventLoop, notificationSending: notificationSendingProvider)
        ).wait()
        XCTAssertTrue(result.item.isReserved!)
    }

    func testAllTests() throws {
        assertAllTests()
    }

}
