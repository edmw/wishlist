@testable import App
@testable import Domain
import Foundation
import NIO

import XCTest
import Testing

final class FavoriteTests: XCTestCase, AppTestCase, HasEntityTestSupport, HasAllTests {

    static var __allTests = [
        ("testProperties", testProperties),
        ("testMapping", testMapping),
        ("testAllTests", testAllTests)
    ]

    typealias EntityType = Favorite
    typealias ModelType = FluentFavorite

    func testProperties() throws {
        entityTestProperties()
    }

    func testMapping() {
        let model = FluentReservation(
            uuid: UUID(),
            status: .open,
            createdAt: Date(),
            itemKey: UUID(),
            holder: Identification()
        )
        let entity = Reservation(from: model)
        XCTAssertEqual(entity.model, model)
    }

    func testAllTests() throws {
        assertAllTests()
    }

}
