@testable import App
@testable import Domain
import Foundation
import Vapor

import XCTest
import Testing

extension EnvironmentKeys {
    static let stringValue = EnvironmentKey<String>("STRING")
    static let intValue = EnvironmentKey<Int>("INT")
    static let urlValue = EnvironmentKey<URL>("URL")
}

final class EnvironmentTests: XCTestCase, AppTestCase, HasAllTests {

    static var __allTests = [
        ("testStringValue", testStringValue),
        ("testIntValue", testIntValue),
        ("testURLValue", testURLValue),
        ("testSiteURL", testSiteURL),
        ("testAllTests", testAllTests)
    ]

    func testStringValue() throws {
        XCTAssertNil(Environment.get(.stringValue))
        assert(
            try Environment.require(.stringValue),
            throws: VaporError.self,
            reflection: .contains("Required environment variable `STRING` missing.")
        )
        setenv("STRING", "hi there", 1)
        XCTAssertEqual(Environment.get(.stringValue)!, "hi there")
        XCTAssertEqual(try Environment.require(.stringValue), "hi there")
    }

    func testIntValue() throws {
        XCTAssertNil(Environment.get(.intValue))
        assert(
            try Environment.require(.intValue),
            throws: VaporError.self,
            reflection: .contains("Required environment variable `INT` missing.")
        )
        setenv("INT", "24", 1)
        XCTAssertEqual(Environment.get(.intValue)!, 24)
        XCTAssertEqual(try Environment.require(.intValue), 24)
        // invalid
        setenv("INT", "nonumber", 1)
        XCTAssertNil(Environment.get(.intValue))
        assert(
            try Environment.require(.intValue),
            throws: VaporError.self,
            reflection: .contains("is not a valid Integer")
        )
    }

    func testURLValue() throws {
        XCTAssertNil(Environment.get(.urlValue))
        assert(
            try Environment.require(.urlValue),
            throws: VaporError.self,
            reflection: .contains("Required environment variable `URL` missing.")
        )
        setenv("URL", "http://example.com/path", 1)
        XCTAssertEqual(
            Environment.get(.urlValue)!.absoluteString,
            "http://example.com/path"
        )
        XCTAssertEqual(
            try Environment.require(.urlValue).absoluteString,
            "http://example.com/path"
        )
        // invalid
        setenv("URL", "\\", 1)
        XCTAssertNil(Environment.get(.urlValue))
        assert(
            try Environment.require(.urlValue),
            throws: VaporError.self,
            reflection: .contains("is not a valid URL")
        )
    }

    func testSiteURL() throws {
        // valid
        let url = "https://localhost:12345"
        setenv("SITE_URL", url, 1)
        XCTAssertEqual(try Environment.requireSiteURL().absoluteString, url)
        // invalid
        setenv("SITE_URL", "https://localhost/", 1)
        assert(
            try Environment.requireSiteURL(),
            throws: VaporError.self,
            reflection: .contains("is not a valid absolute web URL without path")
        )
        setenv("SITE_URL", "localhost", 1)
        assert(
            try Environment.requireSiteURL(),
            throws: VaporError.self,
            reflection: .contains("is not a valid absolute web URL without path")
        )
        setenv("SITE_URL", "", 1)
        assert(
            try Environment.requireSiteURL(),
            throws: VaporError.self,
            reflection: .contains("is not a valid URL")
        )
    }

    func testAllTests() throws {
        assertAllTests()
    }

}
