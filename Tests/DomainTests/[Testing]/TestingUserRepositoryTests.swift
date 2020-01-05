@testable import Domain
import Foundation
import NIO

import XCTest

final class TestingUserRepositoryTests : XCTestCase, HasAllTests {

    static var __allTests = [
        ("testFindId", testFindId),
        ("testCount", testCount),
        ("testAllTests", testAllTests)
    ]

    func testFindId() throws {
        let eventLoop = EmbeddedEventLoop()
        let repository = TestingUserRepository(worker: eventLoop)
        let user = UserSupport.randomUser()
        // save random user
        let savedUser = try repository.save(user: user).wait()
        XCTAssertNotNil(savedUser.userID)
        let foundUser = try repository.find(id: savedUser.userID!).wait()
        XCTAssertEqual(savedUser, foundUser)
    }

    func testCount() throws {
        let eventLoop = EmbeddedEventLoop()
        let repository = TestingUserRepository(worker: eventLoop)
        XCTAssertEqual(try repository.count().wait(), 0)
        let user = UserSupport.randomUser()
        // save new random user
        let _ = try repository.save(user: user).wait()
        XCTAssertEqual(try repository.count().wait(), 1)
        // save same user again
        let _ = try repository.save(user: user).wait()
        XCTAssertEqual(try repository.count().wait(), 1)
        // save other random user
        let _ = try repository.save(user: UserSupport.randomUser()).wait()
        XCTAssertEqual(try repository.count().wait(), 2)
    }

    func testAllTests() {
        assertAllTests()
    }

}
