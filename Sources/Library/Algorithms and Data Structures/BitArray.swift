///////////////////////////////////////////////////////////////////////////////////////////////////
// Wishlist - BitArray
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

// MARK: BitArray

public struct BitArray: MutableCollection, Equatable, Hashable, CustomStringConvertible {

    /// Number of bits in this bit array.
    public private(set) var count: Int

    /// Number of bits set in this bit array.
    public var cardinality: Int {
        var count = 0
        for var word in bits {
            while word != 0 {
                // find lowest bit set and erase it
                word = word ^ (word & ~(word - 1))
                count += 1
            }
        }
        return count
    }

    typealias Word = UInt64
    private static let wordSize = 64
    private static let allSetWord = ~Word()
    private static let allUnsetWord = Word()

    internal var bits: [Word]

    public init(repeating repeatedValue: Bool, count size: Int) {
        precondition(size >= 0, "Can't construct BitArray with count < 0")

        self.count = size

        let wordSize = BitArray.wordSize
        let numberOfWords = (size + wordSize - 1) / wordSize
        let repeatedWordValue = repeatedValue ? BitArray.allSetWord : BitArray.allUnsetWord
        self.bits = [Word](repeating: repeatedWordValue, count: numberOfWords)

        if repeatedValue {
            fixbits()
        }
    }

    public init<S: Collection>(_ elements: S) where S.Element == Bool {
        self.init(repeating: false, count: elements.count)
        var index = 0
        for element in elements {
            self[index] = element
            index += 1
        }
    }

    /// Clears out the bits not used, if `count` is not a multiple of `wordSize`.
    private mutating func fixbits() {
        let wordSize = BitArray.wordSize
        var mask: Word {
            let diff = bits.count * wordSize - count
            if diff > 0 {
                // set the highest bit that's still valid
                let mask = 1 << Word(63 - diff)
                // subtract 1 to turn it into a mask, and add the high bit back in
                return (Word)(mask | (mask - 1))
            }
            return ~Word()
        }
        if bits.isNotEmpty {
            bits[bits.count - 1] &= mask
        }
    }

    internal func check(_ index: Int) -> Bool {
        return index >= 0 && index < count
    }

    internal func addressOf(_ index: Int) -> (Int, Word) {
        precondition(check(index), "Index out of range (\(index))")
        let wordSize = BitArray.wordSize
        return (Int(index / wordSize), Word(bitPattern: 1 << (index % wordSize)))
    }

    public mutating func set(_ index: Int) {
        let (offset, mask) = addressOf(index)
        bits[offset] |= mask
    }

    public mutating func setAll() {
        for index in 0 ..< bits.count {
            bits[index] = BitArray.allSetWord
        }
        fixbits()
    }

    public mutating func unset(_ index: Int) {
        let (offset, mask) = addressOf(index)
        bits[offset] &= ~mask
    }

    public mutating func unsetAll() {
        for index in 0 ..< bits.count {
            bits[index] = BitArray.allUnsetWord
        }
    }

    public func isSet(_ index: Int) -> Bool {
        let (offset, mask) = addressOf(index)
        let bit = (bits[offset] & mask)
        return bit != 0
    }

    // MARK: MutableCollection

    public var startIndex: Int {
        return 0
    }

    public var endIndex: Int {
        return count
    }

    public func index(after index: Int) -> Int {
        return index + 1
    }

    public subscript(index: Int) -> Bool {
        get {
            return isSet(index)
        }
        set {
            newValue ? set(index) : unset(index)
        }
    }

    // MARK: Equatable

    public static func == (lhs: BitArray, rhs: BitArray) -> Bool {
        guard lhs.count == rhs.count else {
            return false
        }
        return lhs.bits.elementsEqual(rhs.bits)
    }

    private static func compare(_ lhs: BitArray, _ rhs: [Bool]) -> Bool {
        guard lhs.count == rhs.count else {
            return false
        }
        for index in 0..<lhs.count where lhs[index] != rhs[index] {
            return false
        }
        return true
    }

    public static func == (lhs: BitArray, rhs: [Bool]) -> Bool {
        return compare(lhs, rhs)
    }

    public static func == (lhs: [Bool], rhs: BitArray) -> Bool {
        return compare(rhs, lhs)
    }

    // MARK: Hashable

    public func hash(into hasher: inout Hasher) {
        for word in bits {
            hasher.combine(word)
        }
    }

    // CustomStringConvertible

    public var description: String {
        var strings = [String]()
        for word in bits {
            strings.append(word.bitString)
        }
        return strings.joined()
    }

}

extension UInt64 {

    public var bitString: String {
        var string = ""
        var word = self
        for _ in 1...64 {
            string += (word & 1 == 1) ? "1" : "0"
            word >>= 1
        }
        return string
    }

}
