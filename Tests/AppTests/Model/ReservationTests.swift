@testable import App
import Vapor
import Fluent

import XCTest

class ReservationTests: XCTestCase, EntityTestsSupport {
    typealias EntityType = Reservation

    func testProperties() {
        entityTestProperties()
    }

}
