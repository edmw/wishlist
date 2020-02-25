import XCTest

public protocol HasAllTests {

    static var __allTests: [(String, (Self) -> () throws -> ())] { get }

}

extension HasAllTests where Self: XCTestCase {

    public func assertAllTests(in file: StaticString = #file, line: UInt = #line) {
        #if os(macOS)
        let allCount = type(of: self).__allTests.count
        let testsCount = type(of: self).defaultTestSuite.testCaseCount
        XCTAssertEqual(allCount, testsCount,
            "\(testsCount - allCount) tests are missing from allTests", file: file, line: line)
        #endif
    }

}
