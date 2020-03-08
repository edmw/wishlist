@testable import Library
import XCTest
import Testing

final class URLTests : XCTestCase, LibraryTestCase, HasAllTests {

    static var __allTests = [
        ("testHasPrefix", testHasPrefix),
        ("testIsLocalFileURL", testIsLocalFileURL),
        ("testIsLocalFileAbsoluteURL", testIsLocalFileAbsoluteURL),
        ("testIsLocalFileRelativeURL", testIsLocalFileRelativeURL),
        ("testAllTests", testAllTests)
    ]

    func testHasPrefix() throws {
        let url1 = URL(string: "https://web.de/products/mail")!
        XCTAssertTrue(url1.hasPrefix(URL(string: "https://web.de")!))
        XCTAssertTrue(url1.hasPrefix(URL(string: "https://web.de/")!))
        XCTAssertTrue(url1.hasPrefix(URL(string: "https://web.de/products")!))
        XCTAssertTrue(url1.hasPrefix(URL(string: "https://web.de/products/")!))
        XCTAssertFalse(url1.hasPrefix(URL(string: "http://web.de")!))
        XCTAssertFalse(url1.hasPrefix(URL(string: "https://web.fr/")!))
        XCTAssertFalse(url1.hasPrefix(URL(string: "http://web.de")!))
        XCTAssertFalse(url1.hasPrefix(URL(string: "http://web.de/produkte/")!))
        let url2 = URL(fileURLWithPath: "/home/user/bin")
        XCTAssertTrue(url2.hasPrefix(URL(string: "file:///home/user")!))
        XCTAssertTrue(url2.hasPrefix(URL(string: "file:///home/user/")!))
        XCTAssertFalse(url2.hasPrefix(URL(string: "file:///home/use/")!))
        XCTAssertFalse(url2.hasPrefix(URL(string: "file:///away/user")!))
        XCTAssertFalse(url2.hasPrefix(URL(string: "file:/home//user")!))
        XCTAssertFalse(url2.hasPrefix(URL(string: "http://home/user")!))
        let url3 = URL(string: "/home/user/bin")!
        XCTAssertTrue(url3.hasPrefix(URL(string: "/home/user")!))
        XCTAssertTrue(url3.hasPrefix(URL(string: "/home/user/")!))
        XCTAssertFalse(url3.hasPrefix(URL(string: "/away/user")!))
        XCTAssertFalse(url3.hasPrefix(URL(string: "/home//user/")!))
        XCTAssertFalse(url3.hasPrefix(URL(string: "file:///home/user")!))
    }

    func testIsLocalFileURL() throws {
        XCTAssertTrue(URL(fileURLWithPath: "/anywhere/on/disk").isLocalFileURL)
        XCTAssertTrue(URL(string: "file:/anywhere/on/disk")!.isLocalFileURL)
        XCTAssertFalse(URL(string: "/withoutscheme/anywhere")!.isLocalFileURL)
        XCTAssertFalse(URL(string: "file://withhost/anywhere")!.isLocalFileURL)
        XCTAssertFalse(URL(string: "http:/anywhere")!.isLocalFileURL)
        XCTAssertFalse(URL(string: "http://withhost/anywhere")!.isLocalFileURL)
    }

    func testIsLocalFileAbsoluteURL() throws {
        XCTAssertTrue(URL(fileURLWithPath: "/anywhere/on/disk").isLocalFileAbsoluteURL)
        XCTAssertTrue(URL(string: "file:///anywhere/on/disk")!.isLocalFileAbsoluteURL)
        XCTAssertFalse(URL(fileURLWithPath: "anywhere/on/disk").isLocalFileAbsoluteURL)
        XCTAssertFalse(URL(string: "file://anywhere/on/disk")!.isLocalFileAbsoluteURL)
    }

    func testIsLocalFileRelativeURL() throws {
        XCTAssertFalse(URL(fileURLWithPath: "/anywhere/on/disk").isLocalFileRelativeURL)
        XCTAssertFalse(URL(string: "file:///anywhere/on/disk")!.isLocalFileRelativeURL)
        XCTAssertTrue(URL(fileURLWithPath: "anywhere/on/disk").isLocalFileRelativeURL)
        XCTAssertTrue(URL(string: "45O/Pl3/PQ3.jpeg")!.isLocalFileRelativeURL)
    }

    func testAllTests() throws {
        assertAllTests()
    }

}
