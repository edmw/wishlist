@testable import Library
import XCTest
import Testing

final class BloomFilterTests : XCTestCase, HasAllTests {

    static var __allTests = [
        ("testInsertAndContains", testInsertAndContains),
        ("testClear", testClear),
        ("testOptimalSize", testOptimalSize),
        ("testOptimalHashCount", testOptimalHashCount),
        ("testEstimatedPopulation", testEstimatedPopulation),
        ("testFalsePositiveProbability", testFalsePositiveProbability),
        ("testAllTests", testAllTests)
    ]

    func testInsertAndContains() throws {
        var filterInt = BloomFilter<Int>(
            expectedNumberOfElements: 1_000,
            falsePositiveProbability: 0.1
        )
        for i in (0 ..< 10) {
            filterInt.insert(i)
        }
        for i in (0 ..< 10) {
            XCTAssertTrue(filterInt.contains(i))
        }
        var filterString = BloomFilter<String>(
            expectedNumberOfElements: 1_000,
            falsePositiveProbability: 0.1
        )
        let strings = (0 ..< 10).map { _ in Lorem.randomString() }
        for string in strings {
            filterString.insert(string)
        }
        for string in strings {
            XCTAssertTrue(filterString.contains(string))
        }
    }

    func testClear() throws {
        var filter = BloomFilter<String>(size: 1_000, hashCount: 3)
        filter.insert("ABC")
        (0 ..< 10).map { _ in Lorem.randomString() }.forEach { filter.insert($0) }
        XCTAssertFalse(filter.isEmpty)
        XCTAssertTrue(filter.contains("ABC"))
        filter.clear()
        XCTAssertTrue(filter.isEmpty)
        XCTAssertFalse(filter.contains("ABC"))
    }

    func testOptimalSize() throws {
        XCTAssertEqual(2, BloomFilter<String>.optimalSize(1, 0.5))
        XCTAssertEqual(48, BloomFilter<String>.optimalSize(10, 0.1))
        XCTAssertEqual(42258, BloomFilter<String>.optimalSize(4_716, 0.0135))
        XCTAssertEqual(33547705, BloomFilter<String>.optimalSize(1_000_000, 0.0000001))
    }

    func testOptimalHashCount() throws {
        XCTAssertEqual(1, BloomFilter<String>.optimalHashCount(1, 2))
        XCTAssertEqual(3, BloomFilter<String>.optimalHashCount(10, 48))
        XCTAssertEqual(6, BloomFilter<String>.optimalHashCount(4_716, 42258))
        XCTAssertEqual(23, BloomFilter<String>.optimalHashCount(1_000_000, 33547705))
    }

    func testEstimatedPopulation() throws {
        var filter = BloomFilter<String>(
            expectedNumberOfElements: 1_000_000,
            falsePositiveProbability: 0.1
        )
        XCTAssertEqual(0, filter.estimatedPopulation)
        filter.insert(Lorem.randomWord())
        XCTAssertEqual(1, filter.estimatedPopulation, accuracy: 0.001)
        filter.clear()
        filter.insert(Lorem.randomStrings(count: 200))
        XCTAssertEqual(200, filter.estimatedPopulation, accuracy: 5)
    }

    func testFalsePositiveProbability() throws {
        var filter1 = BloomFilter<String>(size: 2, hashCount: 1)
        filter1.bits.set(0)
        XCTAssertEqual(0.5, filter1.falsePositiveProbability)
        filter1.bits.set(1)
        XCTAssertEqual(1.0, filter1.falsePositiveProbability)
        var filter2 = BloomFilter<String>(size: 42258, hashCount: 6)
        XCTAssertEqual(0.0, filter2.falsePositiveProbability)
        filter2.bits.set(0)
        XCTAssertGreaterThan(filter2.falsePositiveProbability, 0)
        XCTAssertLessThan(filter2.falsePositiveProbability, 1.8e-28)
        filter2.bits.setAll()
        XCTAssertEqual(1.0, filter2.falsePositiveProbability)
    }

    func testAllTests() throws {
        assertAllTests()
    }

}
