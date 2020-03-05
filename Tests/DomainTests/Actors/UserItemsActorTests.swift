@testable import Domain
import Foundation
import NIO

import XCTest
import Testing

final class UserItemsActorTests : ActorTestCase, HasAllTests {

    static var __allTests = [
        ("testMoveItem", testMoveItem),
        ("testMoveItemWrongUser", testMoveItemWrongUser),
        ("testAllTests", testAllTests)
    ]

    var aUser: User!
    var aList: List!
    var aItem: Item!

    var actor: UserItemsActor!

    override func setUp() {
        super.setUp()

        aUser = try! userRepository.save(user: User.randomUser()).wait()
        aList = try! listRepository.save(list: List.randomList(for: aUser)).wait()
        aItem = try! itemRepository.save(item: Item.randomItem(for: aList)).wait()

        actor = DomainUserItemsActor(
            itemRepository: itemRepository,
            listRepository: listRepository,
            userRepository: userRepository,
            logging: logging,
            recording: recording
        )
    }

    func testMoveItem() throws {
        let anotherList = try! listRepository.save(list: List.randomList(for: aUser)).wait()
        let count = try itemRepository.count(on: aList).wait()
        let result = try! actor.moveItem(
            .specification(
                userBy: aUser.id!,
                listBy: aList.id!,
                itemBy: aItem.id!,
                targetListID: anotherList.id!
            ),
            .boundaries(worker: eventLoop)
        ).wait()
        XCTAssertEqual(result.user, UserRepresentation(aUser))
        XCTAssertEqual(result.item, ItemRepresentation(aItem))
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
            try actor.moveItem(
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

    func testAllTests() throws {
        assertAllTests()
    }

}
