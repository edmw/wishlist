@testable import Domain
import Foundation
import NIO

import XCTest
import Testing

final class UserItemsActorTests : ActorTestCase, DomainTestCase, HasAllTests {

    static var __allTests = [
        ("testMoveItem", testMoveItem),
        ("testMoveItemWrongUser", testMoveItemWrongUser),
        ("testReceiveItem", testReceiveItem),
        ("testAllTests", testAllTests)
    ]

    var aUser: User!
    var aList: List!
    var aItem: Item!

    var aReservedItem: Item!
    var aReservation: Reservation!

    override func setUp() {
        super.setUp()

        aUser = try! userRepository.save(user: User.randomUser()).wait()
        aList = try! listRepository.save(list: List.randomList(for: aUser)).wait()
        aItem = try! itemRepository.save(item: Item.randomItem(for: aList)).wait()

        aReservedItem = try! itemRepository.save(item: Item.randomItem(for: aList)).wait()
        aReservation = try! reservationRepository.save(
            reservation: Reservation(item: aReservedItem, holder: aUser.identification)
        ).wait()
    }

    func testMoveItem() throws {
        let anotherList = try! listRepository.save(list: List.randomList(for: aUser)).wait()
        let count = try itemRepository.count(on: aList).wait()
        let result = try! userItemsActor.moveItem(
            .specification(
                userBy: aUser.id!,
                listBy: aList.id!,
                itemBy: aItem.id!,
                targetListID: anotherList.id!
            ),
            .boundaries(worker: eventLoop)
        ).wait()
        XCTAssertEqual(result.user.id, aUser.id)
        XCTAssertEqual(result.item.id, aItem.id)
        XCTAssertEqual(result.list, ListRepresentation(anotherList))
        XCTAssertEqual(try itemRepository.count(on: aList).wait(), count - 1)
        XCTAssertEqual(try itemRepository.count(on: anotherList).wait(), 1)
        XCTAssertNil(try itemRepository.find(by: aItem.id!, in: aList).wait())
        XCTAssertNotNil(try itemRepository.find(by: aItem.id!, in: anotherList).wait())
    }

    func testMoveItemWrongUser() throws {
        let anotherUser = try! userRepository.save(user: User.randomUser()).wait()
        let anotherList = try! listRepository.save(list: List.randomList(for: anotherUser)).wait()
        assert(
            try userItemsActor.moveItem(
                    .specification(
                        userBy: aUser.id!,
                        listBy: aList.id!,
                        itemBy: aItem.id!,
                        targetListID: anotherList.id!
                    ),
                    .boundaries(worker: eventLoop)
                ).wait(),
            throws: UserItemsActorError.invalidList
        )
    }

    func testReceiveItem() throws {
        let itemRepresentation = ItemRepresentation(aReservedItem, with: aReservation)
        XCTAssertTrue(itemRepresentation.isReserved!)
        XCTAssertTrue(itemRepresentation.receivable!)
        let result = try userItemsActor.receiveItem(
            .specification(userBy: aUser.id!, listBy: aList.id!, itemBy: aReservedItem.id!),
            .boundaries(worker: eventLoop)
        ).wait()
        XCTAssertEqual(result.user.id, aUser.id)
        XCTAssertEqual(result.list.id, aList.id)
        XCTAssertEqual(result.item.id, aReservedItem.id)
        XCTAssertTrue(result.item.isReserved!)
        XCTAssertFalse(result.item.receivable!)
    }

    func testAllTests() throws {
        assertAllTests()
    }

}
