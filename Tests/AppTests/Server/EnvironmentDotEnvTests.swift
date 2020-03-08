@testable import App
@testable import Domain
import Foundation
import Vapor

import XCTest
import Testing

final class EnvironmentDotEnvTests: XCTestCase, AppTestCase, HasAllTests {

    static var __allTests = [
        ("testKeyValue", testKeyValue),
        ("testMultipleKeyValue", testMultipleKeyValue),
        ("testInvalidKeyValue", testInvalidKeyValue),
        ("testComments", testComments),
        ("testAllTests", testAllTests)
    ]

    func testKeyValue() throws {
        // simple
        var records = Environment.parseRecords(of: "hi=there")
        XCTAssertEqual(1, records.count)
        XCTAssertEqual("hi", records[0].key)
        XCTAssertEqual("there", records[0].value)
        // empty
        records = Environment.parseRecords(of: "hi=")
        XCTAssertEqual(1, records.count)
        XCTAssertEqual("", records[0].value)
        // double quotes
        records = Environment.parseRecords(of: "hi=\"there\"")
        XCTAssertEqual(1, records.count)
        XCTAssertEqual("there", records[0].value)
        // single quotes
        records = Environment.parseRecords(of: "hi='there'")
        XCTAssertEqual(1, records.count)
        XCTAssertEqual("there", records[0].value)
        // white space
        records = Environment.parseRecords(of: " hi =  there  ")
        XCTAssertEqual(1, records.count)
        XCTAssertEqual("hi", records[0].key)
        XCTAssertEqual("there", records[0].value)
        // white space within double quotes
        records = Environment.parseRecords(of: " hi = \" there \" ")
        XCTAssertEqual(1, records.count)
        XCTAssertEqual("hi", records[0].key)
        XCTAssertEqual(" there ", records[0].value)
        // white space within single quotes
        records = Environment.parseRecords(of: " hi = ' there ' ")
        XCTAssertEqual(1, records.count)
        XCTAssertEqual("hi", records[0].key)
        XCTAssertEqual(" there ", records[0].value)
        // new lines
        records = Environment.parseRecords(of: "hi=there\\nand\\nthen")
        XCTAssertEqual(1, records.count)
        XCTAssertEqual("there\\nand\\nthen", records[0].value)
        // new lines within double quotes
        records = Environment.parseRecords(of: "hi=\"there\\nand\\nthen\"")
        XCTAssertEqual(1, records.count)
        XCTAssertEqual("there\nand\nthen", records[0].value)
        // new lines within single quotes
        records = Environment.parseRecords(of: "hi='there\\nand\\nthen'")
        XCTAssertEqual(1, records.count)
        XCTAssertEqual("there\\nand\\nthen", records[0].value)
        // with equal sign
        records = Environment.parseRecords(of: "hi=there==")
        XCTAssertEqual(1, records.count)
        XCTAssertEqual("there==", records[0].value)
        // with inner quotes
        records = Environment.parseRecords(of: "hi={\"foo\": \"bar\"}")
        XCTAssertEqual(1, records.count)
        XCTAssertEqual("{\"foo\": \"bar\"}", records[0].value)
        records = Environment.parseRecords(of: "hi='{\"foo\": \"bar\"}'")
        XCTAssertEqual(1, records.count)
        XCTAssertEqual("{\"foo\": \"bar\"}", records[0].value)
        // leading quotes
        records = Environment.parseRecords(of: "hi=\"there")
        XCTAssertEqual(1, records.count)
        XCTAssertEqual("\"there", records[0].value)
        records = Environment.parseRecords(of: "hi='there")
        XCTAssertEqual(1, records.count)
        XCTAssertEqual("'there", records[0].value)
        // trailing quotes
        records = Environment.parseRecords(of: "hi=there\"")
        XCTAssertEqual(1, records.count)
        XCTAssertEqual("there\"", records[0].value)
        records = Environment.parseRecords(of: "hi=there'")
        XCTAssertEqual(1, records.count)
        XCTAssertEqual("there'", records[0].value)
    }

    func testMultipleKeyValue() throws {
        // simple
        var records = Environment.parseRecords(of: "hi=there\nand=here")
        XCTAssertEqual(2, records.count)
        XCTAssertEqual("there", records[0].value)
        XCTAssertEqual("and", records[1].key)
        XCTAssertEqual("here", records[1].value)
        // with empty lines
        records = Environment.parseRecords(of: "hi=there\n \nand=here\n\n")
        XCTAssertEqual(2, records.count)
        XCTAssertEqual("hi", records[0].key)
        XCTAssertEqual("there", records[0].value)
        XCTAssertEqual("and", records[1].key)
        // with comment
        records = Environment.parseRecords(of: "# Test\nhi=there\n# this\nand=here\n\n")
        XCTAssertEqual(2, records.count)
        XCTAssertEqual("hi", records[0].key)
        XCTAssertEqual("there", records[0].value)
        XCTAssertEqual("here", records[1].value)
        // using carrige returns (CRLF)
        records = Environment.parseRecords(of: "hi=there\nand=here\r\nbye=again")
        XCTAssertEqual(3, records.count)
        XCTAssertEqual("there", records[0].value)
        XCTAssertEqual("and", records[1].key)
        // using carrige returns (LFCR)
        records = Environment.parseRecords(of: "hi=there\n\rand=here\r\nbye=again")
        XCTAssertEqual(3, records.count)
        XCTAssertEqual("there", records[0].value)
        XCTAssertEqual("and", records[1].key)
        // using carrige returns (CR only)
        records = Environment.parseRecords(of: "hi=there\nand=here\rbye=again")
        XCTAssertEqual(2, records.count)
        XCTAssertEqual("and", records[1].key)
        XCTAssertEqual("here\rbye=again", records[1].value)
    }

    func testInvalidKeyValue() throws {
        // just separator
        var records = Environment.parseRecords(of: "=")
        XCTAssertEqual(0, records.count)
        // just a value
        records = Environment.parseRecords(of: "there")
        XCTAssertEqual(0, records.count)
    }

    func testComments() throws {
        // only comment
        var records = Environment.parseRecords(of: "# COMMENTS=work\n")
        XCTAssertEqual(0, records.count)
        // only comments
        records = Environment.parseRecords(of: "# FIRST\n# COMMENTS=work\n\n")
        XCTAssertEqual(0, records.count)
        // only comments with empty lines
        records = Environment.parseRecords(of: "# FIRST\n\n \n# COMMENTS=work\n\n")
        XCTAssertEqual(0, records.count)
        // only comments with spaces
        records = Environment.parseRecords(of: "  # FIRST\n  # COMMENTS=work\n\n")
        XCTAssertEqual(0, records.count)
        // comments and values
        records = Environment.parseRecords(
            of: "  # FIRST\nhi=there \n  # COMMENTS=work\n\nhello=friend"
        )
        XCTAssertEqual(2, records.count)
        XCTAssertEqual("hi", records[0].key)
        XCTAssertEqual("there", records[0].value)
        XCTAssertEqual("hello", records[1].key)
        XCTAssertEqual("friend", records[1].value)
    }

    func testAllTests() throws {
        assertAllTests()
    }

}
