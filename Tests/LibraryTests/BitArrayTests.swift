@testable import Library
import XCTest
import Testing

final class BitArrayTests : XCTestCase, LibraryTestCase, HasAllTests {

    static var __allTests = [
        ("testCreate", testCreate),
        ("testSetAll", testSetAll),
        ("testUnsetAll", testUnsetAll),
        ("testSubscriptSet", testSubscriptSet),
        ("testCheckIndex", testCheckIndex),
        ("testAddressOf", testAddressOf),
        ("testEquatable", testEquatable),
        ("testDescription", testDescription),
        ("testAllTests", testAllTests)
    ]

    func testCreate() throws {
        let array1 = BitArray(repeating: true, count: 0)
        XCTAssertEqual(array1.count, 0)
        XCTAssertEqual(array1.cardinality, 0)
        XCTAssertTrue(array1.bits.isEmpty)
        let array2 = BitArray(repeating: true, count: 64)
        XCTAssertEqual(array2.count, 64)
        XCTAssertEqual(array2.cardinality, 64)
        XCTAssertFalse(array2.bits.isEmpty)
        let array3 = BitArray(repeating: false, count: 67)
        XCTAssertEqual(array3.count, 67)
        XCTAssertEqual(array3.cardinality, 0)
        for i in 0..<array3.count {
            XCTAssertFalse(array3.isSet(i))
        }
        XCTAssertEqual(array3.bits.count, 2)
        let array4 = BitArray(repeating: true, count: 79)
        XCTAssertEqual(array4.count, 79)
        XCTAssertEqual(array4.cardinality, 79)
        XCTAssertTrue(array4.isSet(8))
        for i in 0..<array4.count {
            XCTAssertTrue(array4.isSet(i))
        }
        XCTAssertEqual(array4.bits.count, 2)
        let data5 = (0..<315).map { _ in Bool.random() }
        let array5 = BitArray(data5)
        XCTAssertEqual(array5.count, 315)
        XCTAssertEqual(array5.cardinality, data5.filter { $0 == true }.count)
        for i in 0..<data5.count {
            XCTAssertEqual(array5[i], data5[i])
        }
    }

    func testSetAll() throws {
        let array1 = BitArray(repeating: true, count: 72)
        var array2 = BitArray(repeating: false, count: 72)
        array2.setAll()
        XCTAssertEqual(array1, array2)
    }

    func testUnsetAll() throws {
        let array1 = BitArray(repeating: false, count: 72)
        var array2 = BitArray(repeating: true, count: 72)
        array2.unsetAll()
        XCTAssertEqual(array1, array2)
    }

    func testSubscriptSet() throws {
        let data = (0...161).map { _ in Bool.random() }
        var array = BitArray(repeating: false, count: data.count)
        for i in 0..<data.count {
            array[i] = data[i]
            XCTAssertEqual(array[i], data[i])
        }
        XCTAssertTrue(array == data)
    }

    func testCheckIndex() throws {
        let array = BitArray(repeating: true, count: 123)
        XCTAssertTrue(array.check(23))
        XCTAssertFalse(array.check(-17))
        XCTAssertFalse(array.check(123))
    }

    func testAddressOf() throws {
        let array = BitArray(repeating: true, count: 133)
        let address1 = array.addressOf(0)
        XCTAssertEqual(address1.0, 0)
        XCTAssertEqual(address1.1, 1 << 0)
        let address2 = array.addressOf(17)
        XCTAssertEqual(address2.0, 0)
        XCTAssertEqual(address2.1, 1 << 17)
        let address3 = array.addressOf(85)
        XCTAssertEqual(address3.0, 1)
        XCTAssertEqual(address3.1, 1 << 21)
        let address4 = array.addressOf(128)
        XCTAssertEqual(address4.0, 2)
        XCTAssertEqual(address4.1, 1 << 0)
    }

    func testEquatable() throws {
        let data = (0...31).map { _ in Bool.random() }
        let array1 = BitArray(data)
        let array2 = BitArray(data)
        let array3 = BitArray(repeating: true, count: 37)
        XCTAssertEqual(array1, array2)
        XCTAssertNotEqual(array1, array3)
        XCTAssertNotEqual(array2, array3)
        XCTAssertTrue(data == array1)
        XCTAssertTrue(array2 == data)
        XCTAssertFalse(data == array3)
        XCTAssertFalse(array3 == data)
    }

    func testDescription() throws {
        let data1 = "0111010101010".map { $0 == "1" ? true : false }
        let array1 = BitArray(data1)
        XCTAssertEqual(
            String(describing: array1),
            "0111010101010000000000000000000000000000000000000000000000000000"
        )
        let string2 =
            "0101010111101000010101101101010110110011011111111100110101011101" +
            "1010111101010010101010101010101010100001100101010101111010010000"
        let data2 = string2.map { $0 == "1" ? true : false }
        let array2 = BitArray(data2)
        XCTAssertEqual(String(describing: array2), string2)
    }

    func testAllTests() throws {
        assertAllTests()
    }

}
