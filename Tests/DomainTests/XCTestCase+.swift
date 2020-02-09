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

    func assert<T, E: Error>(
        _ expression: @autoclosure () throws -> T,
        throws errortype: E.Type,
        reflection: String,
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
            reflection,
            file: file, line: line
        )
    }

    func assertSameElements<T: Hashable>(_ lhs: [T], _ rhs: [T]) {
        let lhb: [T: Int] = lhs.reduce(into: [:]) {
            $0.updateValue(($0[$1] ?? 0) + 1, forKey: $1)
        }
        let rhb: [T: Int] = rhs.reduce(into: [:]) {
            $0.updateValue(($0[$1] ?? 0) + 1, forKey: $1)
        }
        XCTAssertEqual(lhb.count, rhb.count)
        XCTAssert(
            lhb.allSatisfy { rhb[$0.key] == $0.value }
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
