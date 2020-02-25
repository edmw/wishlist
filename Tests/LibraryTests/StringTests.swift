@testable import Library
import XCTest
import Testing

final class StringTests : XCTestCase, HasAllTests {

    static var __allTests = [
        ("testHasLetters", testHasLetters),
        ("testIsLetters", testIsLetters),
        ("testHasDigits", testHasDigits),
        ("testIsDigits", testIsDigits),
        ("testCapitalizingFirstLetter", testCapitalizingFirstLetter),
        ("testReplacingCharacters", testReplacingCharacters),
        ("testSlugify", testSlugify),
        ("testAllTests", testAllTests)
    ]

    func testHasLetters() throws {
        XCTAssertTrue("abcd".hasLetters)
        XCTAssertTrue("護手ヘスイ似".hasLetters)
        XCTAssertTrue("العظمى".hasLetters)
        XCTAssertFalse("".hasLetters)
        XCTAssertFalse("1234".hasLetters)
    }

    func testIsLetters() throws {
        XCTAssertTrue("abcd".isLetters)
        XCTAssertTrue("護手ヘスイ似".isLetters)
        XCTAssertTrue("العظمى".isLetters)
        XCTAssertTrue("".isLetters)
        XCTAssertFalse("1234".isLetters)
        XCTAssertFalse("護1手ヘスイ似".isLetters)
        XCTAssertFalse("ال3عظمى".isLetters)
    }

    func testHasDigits() throws {
        XCTAssertTrue("1234".hasDigits)
        XCTAssertTrue("abcd4".hasDigits)
        XCTAssertTrue("護手ヘ5スイ似".hasDigits)
        XCTAssertTrue("العظ6مى".hasDigits)
        XCTAssertFalse("".hasDigits)
        XCTAssertFalse("abcd".hasDigits)
        XCTAssertFalse("護手ヘスイ似".hasDigits)
        XCTAssertFalse("العظمى".hasDigits)
    }

    func testIsDigits() throws {
        XCTAssertTrue("1234".isDigits)
        XCTAssertTrue("".isDigits)
        XCTAssertFalse("abcd".isDigits)
        XCTAssertFalse("護手ヘスイ似".isDigits)
        XCTAssertFalse("العظمى".isDigits)
    }

    func testCapitalizingFirstLetter() throws {
        XCTAssertEqual("abcdef".capitalizingFirstLetter(), "Abcdef")
        XCTAssertEqual("ABCDEF".capitalizingFirstLetter(), "ABCDEF")
        XCTAssertEqual("the quick brown fox".capitalizingFirstLetter(), "The quick brown fox")
        var string: String = "abcdef"
        string.capitalizeFirstLetter()
        XCTAssertEqual(string, "Abcdef")
        string = "ABCDEF"
        string.capitalizeFirstLetter()
        XCTAssertEqual(string, "ABCDEF")
        string = "the quick brown fox"
        string.capitalizeFirstLetter()
        XCTAssertEqual(string, "The quick brown fox")
    }

    func testReplacingCharacters() throws {
        XCTAssertEqual("1234567890".replacingCharacters(everyNth: 2, with: "-"), "-2-4-6-8-0")
        XCTAssertEqual("1234567890".replacingCharacters(everyNth: 3, with: "-"), "-23-56-89-")
        XCTAssertEqual("1234567890".replacingCharacters(everyNth: 3, with: "#"), "#23#56#89#")
        XCTAssertEqual("12345678".replacingCharacters(everyNth: 8, with: "="), "=2345678")
    }

    func testSlugify() throws {
        XCTAssertEqual("1234567890".slugify(), "1234567890")
        XCTAssertEqual("12/45&78_0".slugify(), "12-45-78_0")
        XCTAssertEqual("Tränenüberströmt".slugify(), "tranenuberstromt")
        XCTAssertEqual("Суши".slugify(), "susi")
        XCTAssertEqual("寿司".slugify(), "shou-si")
        XCTAssertEqual("سوشي".slugify(), "swshy")
        XCTAssertEqual("😀Happy😄".slugify(), "happy")
        XCTAssertEqual("😀😁😂😃😄".slugify(), "")
    }

    func testAllTests() throws {
        assertAllTests()
    }

}
