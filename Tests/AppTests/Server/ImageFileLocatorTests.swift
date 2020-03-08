@testable import App
@testable import Domain

import XCTest
import Testing


final class ImageFileLocatorTests: XCTestCase, AppTestCase, HasAllTests {

    static var __allTests = [
        ("testCreation", testCreation),
        ("testCreationFailed", testCreationFailed),
        ("testAllTests", testAllTests)
    ]

    func testCreation() throws {
        let loc1 = try ImageFileLocator(
            absoluteURL: URL(fileURLWithPath: "/home/wishlist/images/image1.jpeg"),
            baseURL: URL(fileURLWithPath: "/home/wishlist/images/")
        )
        XCTAssertEqual(loc1.absoluteString, "file:///home/wishlist/images/image1.jpeg")
        let loc2 = try ImageFileLocator(
            absoluteURL: URL(fileURLWithPath: "/home/wishlist/images/path/image1.jpeg"),
            baseURL: URL(fileURLWithPath: "/home/wishlist/images/")
        )
        XCTAssertEqual(loc2.absoluteString, "file:///home/wishlist/images/path/image1.jpeg")
    }

    func testCreationFailed() throws {
        let url1 = URL(string: "file://host/home/wishlist/images/")!
        assert(
            try ImageFileLocator(
                absoluteURL: url1,
                baseURL: URL(fileURLWithPath: "/home/wishlist/images/")
            ),
            throws: ImageFileLocatorCreationError.invalidAbsoluteURL(url1)
        )
        let url2 = URL(string: "http://host/home/wishlist/images/")!
        assert(
            try ImageFileLocator(
                absoluteURL: URL(fileURLWithPath: "/home/wishlist/images/"),
                baseURL: url2
            ),
            throws: ImageFileLocatorCreationError.invalidBaseURL(url2)
        )
        let absoluteURL = URL(fileURLWithPath: "/home/wishlist/images-private/image1.jpeg")
        let baseURL = URL(fileURLWithPath: "/home/wishlist/images/")
        assert(
            try ImageFileLocator(absoluteURL: absoluteURL, baseURL: baseURL),
            throws: ImageFileLocatorCreationError.illegalPrefix(absoluteURL, prefix: baseURL)
        )
        assert(
            try ImageFileLocator(
                absoluteURL: URL(fileURLWithPath: "/home/wishlist/images/"),
                baseURL: URL(fileURLWithPath: "/home/wishlist/images/")
            ),
            throws: ImageFileLocatorCreationError.malformedURL(from: "")
        )
    }

    func testAllTests() throws {
        assertAllTests()
    }

}
