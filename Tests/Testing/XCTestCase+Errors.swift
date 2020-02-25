import XCTest

extension XCTestCase {

    public func assert<T, E: Error>(
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

    public enum ErrorReflection {
        case equals(String)
        case contains(String)
    }

    public func assert<T, E: Error>(
        _ expression: @autoclosure () throws -> T,
        throws errortype: E.Type,
        reflection: ErrorReflection,
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

        let reflectedError = String(reflecting: thrownError as! E)
        switch reflection {
        case .equals(let string):
            XCTAssertEqual(reflectedError, string, file: file, line: line)
        case .contains(let string):
            XCTAssertTrue(reflectedError.contains(string), file: file, line: line)
        }
    }

}

