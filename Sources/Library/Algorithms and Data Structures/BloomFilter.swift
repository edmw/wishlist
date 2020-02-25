///////////////////////////////////////////////////////////////////////////////////////////////////
// Wishlist - BloomFilter
//
// Copyright (c) 2019-2020 Michael Baumgärtner
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
///////////////////////////////////////////////////////////////////////////////////////////////////

import Foundation

// MARK: BloomFilter

public struct BloomFilter<Element: Hashable> {

    internal var bits: BitArray

    internal let seeds: [Int]

    /// Constructs a new Bloom Filter by specifying the expected size of the filter and the
    /// tolerable false positive probability. The size of the filter in bits and the optimal
    /// number of hash functions will be inferred from this.
    public init(expectedNumberOfElements: Int, falsePositiveProbability: Double = 0.01) {
        let size = BloomFilter.optimalSize(expectedNumberOfElements, falsePositiveProbability)
        let hashCount = BloomFilter.optimalHashCount(expectedNumberOfElements, size)
        self.init(size: size, hashCount: hashCount)
    }

    /// Calculates the optimal size of the filter in bits given expected number of elements and
    /// tolerable false positive rate.
    /// - Parameter n: expectedNumberOfElements - expected size of the filter
    /// - Parameter p: falsePositiveProbability - tolerable false positive probability
    // swiftlint:disable identifier_name
    internal static func optimalSize(_ n: Int, _ p: Double) -> Int {
        precondition(n > 0,
            "Can't calculate optimal size with expected number of elements <= 0"
        )
        precondition(p > 0 && p < 1,
            "Can't calculate optimal size with tolerable false positive probability <= 0 or >= 1"
        )
        return Int(ceil(-1.0 * (Double(n) * log(p)) / pow(log(2.0), 2.0)))
    }
    // swiftlint:enable identifier_name

    /// Calculates the optimal number of hash functions given the the expected size of the filter
    /// and the size of filter in bits.
    /// - Parameter n: expectedNumberOfElements - expected size of the filter
    /// - Parameter m: size - size of the filter in bits
    // swiftlint:disable identifier_name
    internal static func optimalHashCount(_ n: Int, _ m: Int) -> Int {
        precondition(n > 0,
            "Can't calculate optimal hash count with expected number of elements <= 0"
        )
        precondition(m > 0,
            "Can't calculate optimal hash count with size <= 0"
        )
        return Int(round(log(2.0) * Double(m) / Double(n)))
    }
    // swiftlint:enable identifier_name

    /// Constructs a new Bloom Filter using the specified size in bits and the specified number
    /// of hash functions.
    public init(size: Int, hashCount: Int) {
        precondition(size > 0, "Can't construct BloomFilter with size <= 0")

        bits = BitArray(repeating: false, count: size)
        seeds = (0 ..< hashCount).map { _ in Int.random(in: 0 ..< Int.max) }
    }

    /// Adds the passed value to the filter.
    /// - Parameter element: element value to add
    public mutating func insert(_ element: Element) {
        hashes(for: element).forEach { hash in
            bits[hash % bits.count] = true
        }
    }

    /// Adds the passed values to the filter.
    /// - Parameter values: element values to add
    public mutating func insert(_ elements: [Element]) {
        for element in elements {
            insert(element)
        }
    }

    /// Tests whether an element is present in the filter
    /// (subject to the specified false positive rate).
    /// - Parameter value: element value to test
    public func contains(_ element: Element) -> Bool {
        return hashes(for: element).allSatisfy { hash in
            bits[hash % bits.count]
        }
    }

    /// Tests whether an element is present in the filter
    /// (subject to the specified false positive rate).
    /// - Parameter value: element value to test
    public func containsNot(_ element: Element) -> Bool {
        return !contains(element)
    }

    /// Clears the filter from all elements.
    public mutating func clear() {
        bits.unsetAll()
    }

    /// `True` if the filter does not contain any elements.
    public var isEmpty: Bool {
        return bits.cardinality == 0
    }

    public var estimatedPopulation: Double {
        // swiftlint:disable identifier_name
        let m = Double(bits.count)
        let k = Double(seeds.count)
        let cardinality = Double(bits.cardinality)
        return (-m / k * log(1.0 - cardinality / m))
        // swiftlint:enable identifier_name
    }

    public var falsePositiveProbability: Double {
        // swiftlint:disable identifier_name
        let population = estimatedPopulation
        let m = Double(bits.count)
        let k = Double(seeds.count)
        return pow((1.0 - exp(-k * population / m)), k)
        // swiftlint:enable identifier_name
    }

    private func hashes(for element: Element) -> [Int] {
        return seeds.map { seed -> Int in
            var hasher = Hasher()
            hasher.combine(element)
            hasher.combine(seed)
            return abs(hasher.finalize())
        }
    }

}
