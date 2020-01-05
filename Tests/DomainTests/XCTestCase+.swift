import XCTest

extension XCTestCase {

    func assert<T, E: Error>(
        _ expression: @autoclosure () throws -> T,
        throws error: E,
        in file: StaticString = #file,
        line: UInt = #line
    ) {
        var thrownError: Error?

        XCTAssertThrowsError(try expression(), file: file, line: line) {
            thrownError = $0
        }
        XCTAssertTrue(
            thrownError is E,
            "Unexpected error type: \(type(of: thrownError))",
            file: file, line: line
        )
        XCTAssertEqual(
            String(reflecting: thrownError as! E),
            String(reflecting: error),
            file: file, line: line
        )
    }

}

protocol HasAllTests {

    static var __allTests: [(String, (Self) -> () throws -> ())] { get }

}

extension HasAllTests where Self: XCTestCase {

    func assertAllTests() {
        #if os(macOS)
        let allCount = type(of: self).__allTests.count
        let testsCount = type(of: self).defaultTestSuite.testCaseCount
        XCTAssertEqual(allCount, testsCount,
            "\(testsCount - allCount) tests are missing from allTests")
        #endif
    }

}
