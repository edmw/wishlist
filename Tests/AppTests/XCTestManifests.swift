import XCTest

extension AppTests {
    static let __allTests = [
        ("testNothing", testNothing),
    ]
}

extension UUIDTests {
    static let __allTests = [
        ("testDecode", testDecode),
        ("testEncode", testEncode),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(AppTests.__allTests),
        testCase(UUIDTests.__allTests),
    ]
}
#endif
