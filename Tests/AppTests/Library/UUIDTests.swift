import App
import XCTest

final class UUIDTests : XCTestCase {
    
    func testEncode() throws {
        let uuid0 = UUID(uuidString: "00000000-0000-0000-0000-000000000000")
        XCTAssertEqual(uuid0?.base62String, "0000000000000000")
        let uuid1 = UUID(uuidString: "86d5c52d-e7bf-452a-ac0b-064f65f821e8")
        XCTAssertEqual(uuid1?.base62String, "46QfEaPfUXMcvlP4dPgQJ6")
        let uuid2 = UUID(uuidString: "0000c52d-e7bf-452a-ac0b-064f65f821e8")
        XCTAssertEqual(uuid2?.base62String, "00Lp4i5fOQ8Rlp9Ajg5SC")
    }
    
    func testDecode() throws {
        let uuid0 = UUID(base62String: "0000000000000000")
        XCTAssertEqual(uuid0?.uuidString, "00000000-0000-0000-0000-000000000000")
        let uuid1 = UUID(base62String: "46QfEaPfUXMcvlP4dPgQJ6")
        XCTAssertEqual(uuid1?.uuidString, "86D5C52D-E7BF-452A-AC0B-064F65F821E8")
        let uuid2 = UUID(base62String: "00Lp4i5fOQ8Rlp9Ajg5SC")
        XCTAssertEqual(uuid2?.uuidString, "0000C52D-E7BF-452A-AC0B-064F65F821E8")
    }
    
}
