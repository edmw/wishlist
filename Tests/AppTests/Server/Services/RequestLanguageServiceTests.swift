@testable import App
import Vapor
import VaporTestTools

import XCTest
import Testing

final class RequestLanguageServiceTests : XCTestCase, HasAllTests {

    static var __allTests = [
        ("testDescription", testDescription),
        ("testParseNone", testParseNone),
        ("testParseEmpty", testParseEmpty),
        ("testParseSimple", testParseSimple),
        ("testParseRegion", testParseRegion),
        ("testParseScript", testParseScript),
        ("testParseQuality", testParseQuality),
        ("testParseWildcard", testParseWildcard),
        ("testParseSort", testParseSort),
        ("testParseWhitespace", testParseWhitespace),
        ("testParseFull", testParseFull),
        ("testParseCache", testParseCache),
        ("testPick", testPick),
        ("testPickCase", testPickCase),
        ("testPickFallback", testPickFallback),
        ("testAllTests", testAllTests)
    ]

    var app: Application!

    // MARK: Setup

    override func setUp() {
        super.setUp()

        app = try! Application.testable()
    }

    fileprivate func buildRequest(acceptLanguage header: String?) -> Request {
        let request = HTTPRequest.testable.get(
            uri: "/",
            headers: header != nil ? ["Accept-Language": header!] : [:]
        )
        return Request(http: request, using: app)
    }

    func testDescription() throws {
        let language = RequestLanguage("de")
        XCTAssertEqual(
            String(describing: language),
            "Language(de, quality: 1.0)"
        )
        let languageWithRegion = RequestLanguage("en", "US", nil, 0.8)
        XCTAssertEqual(
            String(describing: languageWithRegion),
            "Language(en, region: US, quality: 0.8)"
        )
        let languageWithScript = RequestLanguage("zh", "CN", "Hant", 0.8)
        XCTAssertEqual(
            String(describing: languageWithScript),
            "Language(zh, region: CN, script: Hant, quality: 0.8)"
        )
    }

    func testParseNone() throws {
        let languages = try RequestLanguageService().parse(on: buildRequest(acceptLanguage: nil))
        XCTAssertEqual(languages.count, 0)
    }

    func testParseEmpty() throws {
        let languages = try RequestLanguageService().parse(on: buildRequest(acceptLanguage: ""))
        XCTAssertEqual(languages.count, 0)
    }

    func testParseSimple() throws {
        let languages = try RequestLanguageService()
            .parse(on: buildRequest(acceptLanguage: "fr"))
        XCTAssertEqual(languages.count, 1)
        XCTAssertEqual(languages[0].code, "fr")
        XCTAssertNil(languages[0].region)
        XCTAssertNil(languages[0].script)
        XCTAssertEqual(languages[0].quality, 1.0)
    }

    func testParseRegion() throws {
        let languages = try RequestLanguageService()
            .parse(on: buildRequest(acceptLanguage: "en-GB"))
        XCTAssertEqual(languages.count, 1)
        XCTAssertEqual(languages[0].code, "en")
        XCTAssertEqual(languages[0].region, "GB")
        XCTAssertNil(languages[0].script)
        XCTAssertEqual(languages[0].quality, 1.0)
    }

    func testParseScript() throws {
        let languages = try RequestLanguageService()
            .parse(on: buildRequest(acceptLanguage: "zh-Hant-cn"))
        XCTAssertEqual(languages.count, 1)
        XCTAssertEqual(languages[0].code, "zh")
        XCTAssertEqual(languages[0].region, "cn")
        XCTAssertEqual(languages[0].script, "Hant")
        XCTAssertEqual(languages[0].quality, 1.0)
    }

    func testParseQuality() throws {
        let languages = try RequestLanguageService()
            .parse(on: buildRequest(acceptLanguage: "de-CH;q=0.8"))
        XCTAssertEqual(languages.count, 1)
        XCTAssertEqual(languages[0].code, "de")
        XCTAssertEqual(languages[0].region, "CH")
        XCTAssertNil(languages[0].script)
        XCTAssertEqual(languages[0].quality, 0.8)
    }

    func testParseWildcard() throws {
        let languages = try RequestLanguageService()
            .parse(on: buildRequest(acceptLanguage: "fr-CA,*;q=0.8"))
        XCTAssertEqual(languages.count, 2)
        XCTAssertEqual(languages[0].code, "fr")
        XCTAssertEqual(languages[0].region, "CA")
        XCTAssertNil(languages[0].script)
        XCTAssertEqual(languages[0].quality, 1.0)
        XCTAssertEqual(languages[1].code, "*")
        XCTAssertNil(languages[1].region)
        XCTAssertNil(languages[1].script)
        XCTAssertEqual(languages[1].quality, 0.8)
    }

    func testParseSort() throws {
        let languages = try RequestLanguageService()
            .parse(on: buildRequest(acceptLanguage: "fr-CA,fr;q=0.2,en-US;q=0.6,en;q=0.4,*;q=0.5"))
        XCTAssertEqual(languages.count, 5)
        XCTAssertEqual(languages[0].code, "fr")
        XCTAssertEqual(languages[0].region, "CA")
        XCTAssertEqual(languages[1].code, "en")
        XCTAssertEqual(languages[1].region, "US")
        XCTAssertEqual(languages[2].code, "*")
        XCTAssertNil(languages[2].region)
        XCTAssertEqual(languages[3].code, "en")
        XCTAssertNil(languages[3].region)
        XCTAssertEqual(languages[4].code, "fr")
        XCTAssertNil(languages[4].region)
    }

    func testParseWhitespace() throws {
        let languages = try RequestLanguageService()
            .parse(on: buildRequest(acceptLanguage: "fr-CA, fr;q=0.8,  en-US;q=0.6,   *;q=0.1"))
        XCTAssertEqual(languages.count, 4)
        XCTAssertEqual(languages[0].code, "fr")
        XCTAssertEqual(languages[1].code, "fr")
        XCTAssertEqual(languages[2].code, "en")
        XCTAssertEqual(languages[3].code, "*")
    }

    func testParseFull() throws {
        let languages = try RequestLanguageService()
            .parse(on: buildRequest(acceptLanguage: "fr-CH, fr;q=0.9, en;q=0.8, de;q=0.7, *;q=0.5"))
        XCTAssertEqual(languages.count, 5)
        XCTAssertEqual(languages[0].code, "fr")
        XCTAssertEqual(languages[1].code, "fr")
        XCTAssertEqual(languages[2].code, "en")
        XCTAssertEqual(languages[3].code, "de")
        XCTAssertEqual(languages[4].code, "*")
    }

    func testParseCache() throws {
        let request = buildRequest(acceptLanguage: "fr-CH, fr;q=0.9, en;q=0.8, de;q=0.7, *;q=0.5")
        let service = RequestLanguageService()
        let _ = try service.parse(on: request)
        let _ = try service.parse(on: request)
    }

    func testPick() throws {
        let language = try RequestLanguageService()
            .pick(
                from: ["en", "fr"],
                on: buildRequest(acceptLanguage: "fr-CH, fr;q=0.9, en;q=0.8, de;q=0.7, *;q=0.5"),
                fallback: "de"
            )
        XCTAssertEqual(language, "fr")
    }

    func testPickCase() throws {
        let language = try RequestLanguageService()
            .pick(
                from: ["eN", "Fr"],
                on: buildRequest(acceptLanguage: "fR-Ca, fr;q=0.2, en-US;q=0.6, en;q=0.4, *;q=0.5"),
                fallback: "de"
            )
        XCTAssertEqual(language, "fR")
    }

    func testPickFallback() throws {
        let language1 = try RequestLanguageService()
            .pick(
                from: [],
                on: buildRequest(acceptLanguage: "fr-CH, fr;q=0.9, en;q=0.8, de;q=0.7, *;q=0.5"),
                fallback: "de"
        )
        XCTAssertEqual(language1, "de")
        let language2 = try RequestLanguageService()
            .pick(
                from: ["br", "pl"],
                on: buildRequest(acceptLanguage: "fr-CH, fr;q=0.9, en;q=0.8, de;q=0.7, *;q=0.5"),
                fallback: "de"
        )
        XCTAssertEqual(language2, "de")
        let language3 = try RequestLanguageService()
            .pick(
                from: ["br", "pl"],
                on: buildRequest(acceptLanguage: nil),
                fallback: "de"
        )
        XCTAssertEqual(language3, "de")
    }

    func testAllTests() {
        assertAllTests()
    }

}
