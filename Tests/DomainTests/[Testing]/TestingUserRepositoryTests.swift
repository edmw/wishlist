@testable import Domain
import Foundation
import NIO

import XCTest
import Testing

final class TestingUserRepositoryTests : XCTestCase, HasAllTests {

    static var __allTests = [
        ("testFindId", testFindId),
        ("testFindIdentification", testFindIdentification),
        ("testAll", testAll),
        ("testCount", testCount),
        ("testAllTests", testAllTests)
    ]

    var eventLoop: EventLoop!

    var repository: UserRepository!

    override func setUp() {
         super.setUp()

         eventLoop = EmbeddedEventLoop()

         repository = TestingUserRepository(worker: eventLoop)
    }

    func testFindId() throws {
        let user = User.randomUser()
        // save random user
        let savedUser = try repository.save(user: user).wait()
        XCTAssertNotNil(savedUser.id)
        let foundUser = try repository.find(id: savedUser.id!).wait()
        XCTAssertEqual(savedUser, foundUser)
        let notfoundUser = try repository.find(id: UserID()).wait()
        XCTAssertNil(notfoundUser)
        let foundUserIf = try repository.findIf(id: savedUser.id!).wait()
        XCTAssertEqual(savedUser, foundUserIf)
        let notFoundUserIf = try repository.findIf(id: nil).wait()
        XCTAssertNil(notFoundUserIf)
    }

    func testFindIdentification() throws {
        let user = User.randomUser()
        // save random user
        let savedUser = try repository.save(user: user).wait()
        XCTAssertNotNil(savedUser.id)
        let foundUser = try repository.find(identification: user.identification).wait()
        XCTAssertEqual(savedUser, foundUser)
        let notfoundUser = try repository.find(identification: Identification()).wait()
        XCTAssertNil(notfoundUser)
    }

    func testAll() throws {
        XCTAssertEqual(0, try repository.all().wait().count)
        let user1 = User.randomUser()
        let _ = try repository.save(user: user1).wait()
        var users = try repository.all().wait()
        XCTAssertEqual(1, users.count)
        assertSameElements(users, [user1])
        // save new random user
        let user2 = User.randomUser()
        let _ = try repository.save(user: user2).wait()
        users = try repository.all().wait()
        XCTAssertEqual(2, users.count)
        assertSameElements(users, [user2, user1])
    }

    func testCount() throws {
        XCTAssertEqual(0, try repository.count().wait())
        let user = User.randomUser()
        // save new random user
        let _ = try repository.save(user: user).wait()
        XCTAssertEqual(1, try repository.count().wait())
        // save same user again
        let _ = try repository.save(user: user).wait()
        XCTAssertEqual(1, try repository.count().wait())
        // save other random user
        let _ = try repository.save(user: User.randomUser()).wait()
        XCTAssertEqual(2, try repository.count().wait())
    }

    func testAllTests() {
        assertAllTests()
    }

}
