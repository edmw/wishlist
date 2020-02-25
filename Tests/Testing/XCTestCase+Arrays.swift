import XCTest

extension XCTestCase {

    public func assertSameElements<T: Hashable>(
        _ lhs: [T],
        _ rhs: [T],
        in file: StaticString = #file,
        line: UInt = #line
    ) {
        let lhb: [T: Int] = lhs.reduce(into: [:]) {
            $0.updateValue(($0[$1] ?? 0) + 1, forKey: $1)
        }
        let rhb: [T: Int] = rhs.reduce(into: [:]) {
            $0.updateValue(($0[$1] ?? 0) + 1, forKey: $1)
        }
        XCTAssertEqual(lhb.count, rhb.count, file: file, line: line)
        XCTAssert(
            lhb.allSatisfy { rhb[$0.key] == $0.value },
            file: file, line: line
        )
    }

}
