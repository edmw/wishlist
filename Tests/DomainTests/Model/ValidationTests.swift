@testable import Domain
import Foundation
import NIO

import XCTest
import Testing

final class ValidationTests: XCTestCase, DomainTestCase, HasAllTests {

    static var __allTests = [
        ("testValidate", testValidate),
        ("testValidateWithErrors", testValidateWithErrors),
        ("testValidateWithFailedKeyPaths", testValidateWithFailedKeyPaths),
        ("testNil", testNil),
        ("testEmpty", testEmpty),
        ("testAlphanumeric", testAlphanumeric),
        ("testCharacterSet", testCharacterSet),
        ("testCountCharacters", testCountCharacters),
        ("testCountItems", testCountItems),
        ("testURL", testURL),
        ("testNotOperator", testNotOperator),
        ("testAndOperator", testAndOperator),
        ("testOrOperator", testOrOperator),
        ("testAllTests", testAllTests)
    ]

    struct Values: ValueValidatable {

        var lengthLimitedAlphanumericString: String
        var notNilAndValidPushoverKey: PushoverKey?
        var notNilAndValidEmail: String?
        var nilOrURL: String?
        var notEmptyList: [String]

        static func valueValidations() throws -> ValueValidations<ValidationTests.Values> {
            var validations = ValueValidations(ValidationTests.Values.self)
            validations.add(
                \.lengthLimitedAlphanumericString,
                "lengthLimitedAlphanumericString",
                .count(5...) && .alphanumeric
            )
            validations.add(
                \.notNilAndValidPushoverKey,
                "notNilAndValidPushoverKey",
                .pushoverKey && !.nil
            )
            validations.add(
                \.notNilAndValidEmail,
                "notNilAndValidEmail",
                !.nil && .email
            )
            validations.add(
                \.nilOrURL,
                "nilOrURL",
                .nil || .url
            )
            validations.add(
                \.notEmptyList,
                "notEmptyList",
                !.empty
            )
            return validations
        }

    }

    func testValidate() throws {
        let values = Values(
            lengthLimitedAlphanumericString: "ABCDEF",
            notNilAndValidPushoverKey: PushoverKey(string: "012345678901234567890123456789"),
            notNilAndValidEmail: "someone@somewhere.us",
            nilOrURL: nil,
            notEmptyList: ["1","2"]
        )
        try values.validateValues()
    }

    func testValidateWithErrors() throws {
        let values = Values(
            lengthLimitedAlphanumericString: "ABC",
            notNilAndValidPushoverKey: PushoverKey(string: "0123456789"),
            notNilAndValidEmail: "someone@@somewhere.us",
            nilOrURL: "notanurl",
            notEmptyList: []
        )
        assert(
            try values.validateValues(),
            throws: ValueValidationErrors<ValidationTests.Values>.self,
            reflection: .equals("Value validation failed on 'lengthLimitedAlphanumericString' with 'is less than required minimum of 5', Value validation failed on 'nilOrURL' with 'is not nil and is not a valid URL', Value validation failed on 'notEmptyList' with 'is empty', Value validation failed on 'notNilAndValidEmail' with 'is not a valid email (pattern)', Value validation failed on 'notNilAndValidPushoverKey' with 'is not a valid pushover key (pattern)'")
        )
    }

    func testValidateWithFailedKeyPaths() throws {
        let values = Values(
            lengthLimitedAlphanumericString: "ABCDEF",
            notNilAndValidPushoverKey: PushoverKey(string: "012345678901234567890123456789"),
            notNilAndValidEmail: "someone@@somewhere.us",
            nilOrURL: "notanurl",
            notEmptyList: []
        )
        do {
            try values.validateValues()
        }
        catch let error as ValueValidationErrors<ValidationTests.Values> {
            assertSameElements(
                error.failedKeyPaths,
                [
                    \Values.notNilAndValidEmail,
                    \Values.nilOrURL,
                    \Values.notEmptyList
                ]
            )
        }
    }

    func testNil() throws {
        try ValueValidator<String?>.nil.validate(nil)
        assert(
            try ValueValidator<String?>.nil.validate("something"),
            throws: ValueValidationError("is not nil")
        )
    }

    func testEmpty() throws {
        try ValueValidator<String>.empty.validate("")
        assert(
            try ValueValidator<String>.empty.validate("something"),
            throws: ValueValidationError("is not empty")
        )
        try ValueValidator<[Int]>.empty.validate([])
        assert(
            try ValueValidator<[Int]>.empty.validate([1, 2]),
            throws: ValueValidationError("is not empty")
        )
    }

    func testAlphanumeric() throws {
        try ValueValidator<String>
            .alphanumeric
            .validate("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789")
        try ValueValidator<String>
            .alphanumeric
            .validate("護手ヘスイ似")
        assert(
            try ValueValidator<String>
                .alphanumeric
                .validate("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"),
            throws: ValueValidationError("contains an invalid character: '+'")
        )
        assert(
            try ValueValidator<String>
                .alphanumeric
                .validate("😀😁😂😃😄"),
            throws: ValueValidationError("contains an invalid character: '😀'")
        )
    }

    func testCharacterSet() throws {
        try ValueValidator<String>
            .characterSet(.lowercaseLetters)
            .validate("abcd")
        try ValueValidator<String>
            .characterSet(.decimalDigits)
            .validate("12345")
        try ValueValidator<String>
            .characterSet(.symbols)
            .validate("😀😁😂😃😄")
    }

    func testCountCharacters() throws {
        let validator = ValueValidator<String>.count(1...6)
        try validator.validate("1")
        try validator.validate("123")
        try validator.validate("123456")
        assert(
            try validator.validate(""),
            throws: ValueValidationError("is less than required minimum of 1")
        )
        assert(
            try validator.validate("1234567"),
            throws: ValueValidationError("is greater than required maximum of 6")
        )
    }

    func testCountItems() throws {
        let validator = ValueValidator<[Int]>.count(1..<6)
        try validator.validate([1])
        try validator.validate([1, 2, 3])
        try validator.validate([1, 2, 3, 4, 5])
        assert(
            try validator.validate([]),
            throws: ValueValidationError("is less than required minimum of 1")
        )
        assert(
            try validator.validate([1, 2, 3, 4, 5, 6]),
            throws: ValueValidationError("is greater than required maximum of 5")
        )
    }

    func testURL() throws {
        try ValueValidator<String>.url.validate("http://www.somewhere.com/")
        try ValueValidator<String>.url.validate("https://www.somewhere.com/somepath.png")
        try ValueValidator<String>.url.validate("https://somewhere.com/somepath.png")
        try ValueValidator<String>.url.validate("file:///somewhere/in/the/filesystem.png")
        assert(
            try ValueValidator<String>.url.validate("www.somedomain.com/"),
            throws: ValueValidationError("is not a valid URL")
        )
        assert(
            try ValueValidator<String>.url.validate("bananas"),
            throws: ValueValidationError("is not a valid URL")
        )
    }

    func testNotOperator() throws {
        try (!ValueValidator<String>.empty).validate("abc")
        assert(
            try (!ValueValidator<String>.empty).validate(""),
            throws: ValueValidationError("is empty")
        )
        try (!ValueValidator<String>.alphanumeric)
            .validate("ABC+/")
        assert(
            try (!ValueValidator<String>.alphanumeric)
                .validate("ABCDEF"),
            throws: ValueValidationError("is in character set")
        )
    }

    func testAndOperator() throws {
        try (ValueValidator<String>.alphanumeric && ValueValidator<String>.count(...6))
            .validate("abc")
        assert(
            try (ValueValidator<String>.alphanumeric && ValueValidator<String>.count(...6))
                .validate("abc-+="),
            throws: AndValidatorError.self,
            reflection: .equals("Value validation failed with 'contains an invalid character: '-''")
        )
        assert(
            try (ValueValidator<String>.alphanumeric && ValueValidator<String>.count(...6))
                .validate("abcdefgh"),
            throws: AndValidatorError.self,
            reflection: .equals("Value validation failed with 'is greater than required maximum of 6'")
        )
        assert(
            try (ValueValidator<String>.alphanumeric && ValueValidator<String>.count(...6))
                .validate("ab+defgh"),
            throws: AndValidatorError.self,
            reflection: .equals("Value validation failed with 'contains an invalid character: '+' and is greater than required maximum of 6'")
        )
    }

    func testOrOperator() throws {
        try (ValueValidator<String>.alphanumeric || ValueValidator<String>.count(...6))
            .validate("abc")
        try (ValueValidator<String>.alphanumeric || ValueValidator<String>.count(...6))
            .validate("abcdefgh")
        try (ValueValidator<String>.alphanumeric || ValueValidator<String>.count(...6))
            .validate("+++")
        assert(
            try (ValueValidator<String>.alphanumeric || ValueValidator<String>.count(...6))
                .validate("ab+defgh"),
            throws: OrValidatorError.self,
            reflection: .equals("Value validation failed with 'contains an invalid character: '+' and is greater than required maximum of 6'")
        )
    }

    func testAllTests() throws {
        assertAllTests()
    }

}
