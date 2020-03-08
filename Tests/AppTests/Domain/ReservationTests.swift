@testable import App
@testable import Domain
import Foundation
import NIO

import XCTest
import Testing

final class ReservationTests: XCTestCase, AppTestCase, HasEntityTestSupport, HasAllTests {

    static var __allTests = [
        ("testProperties", testProperties),
        ("testAllTests", testAllTests)
    ]

    typealias EntityType = Reservation
    typealias ModelType = FluentReservation

    func testProperties() throws {
        entityTestProperties()
    }

    func testAllTests() throws {
        assertAllTests()
    }

}
