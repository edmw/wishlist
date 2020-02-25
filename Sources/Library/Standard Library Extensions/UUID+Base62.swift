///////////////////////////////////////////////////////////////////////////////////////////////////
// Wishlist - UUID+Base62
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

// MARK: UUID

extension UUID {

    public var uuidBytes: [UInt8] {
        return [
            uuid.0,
            uuid.1,
            uuid.2,
            uuid.3,
            uuid.4,
            uuid.5,
            uuid.6,
            uuid.7,
            uuid.8,
            uuid.9,
            uuid.10,
            uuid.11,
            uuid.12,
            uuid.13,
            uuid.14,
            uuid.15
        ]
    }

    private static let translateByteToCharacter: [UInt8: Character] = [
        0: "0", 1: "1", 2: "2", 3: "3", 4: "4", 5: "5", 6: "6", 7: "7", 8: "8", 9: "9",

        10: "A", 11: "B", 12: "C", 13: "D", 14: "E", 15: "F", 16: "G", 17: "H", 18: "I", 19: "J",
        20: "K", 21: "L", 22: "M", 23: "N", 24: "O", 25: "P", 26: "Q", 27: "R", 28: "S", 29: "T",
        30: "U", 31: "V", 32: "W", 33: "X", 34: "Y", 35: "Z",

        36: "a", 37: "b", 38: "c", 39: "d", 40: "e", 41: "f", 42: "g", 43: "h", 44: "i", 45: "j",
        46: "k", 47: "l", 48: "m", 49: "n", 50: "o", 51: "p", 52: "q", 53: "r", 54: "s", 55: "t",
        56: "u", 57: "v", 58: "w", 59: "x", 60: "y", 61: "z"
    ]

    private static let translateCharacterToByte: [Character: UInt8] =
        Dictionary(uniqueKeysWithValues: translateByteToCharacter.map { ($1, $0) })

    private enum Base62Error: Error {
        case illegalCharacter
    }

    public init?(base62String string: String) {
        let bytes: [UInt8]
        do {
            bytes =
                UUID.convert(
                    bytes: try string.map {
                        guard let byte = UUID.translateCharacterToByte[$0] else {
                            throw Base62Error.illegalCharacter
                        }
                        return byte
                    },
                    fromBase: 62,
                    toBase: 256
            )
        }
        catch {
            return nil
        }
        guard bytes.count == 16 else {
            return nil
        }
        self.init(uuid: uuid_t(
            bytes[0],
            bytes[1],
            bytes[2],
            bytes[3],
            bytes[4],
            bytes[5],
            bytes[6],
            bytes[7],
            bytes[8],
            bytes[9],
            bytes[10],
            bytes[11],
            bytes[12],
            bytes[13],
            bytes[14],
            bytes[15]
        ))
    }

    public var base62String: String {
        return convertedToBase62String()
    }

    public func convertedToBase62String() -> String {
        let characters: [Character]
        characters =
            UUID.convert(
                bytes: uuidBytes,
                fromBase: 256,
                toBase: 62
            )
            .map {
                guard let character = UUID.translateByteToCharacter[$0] else {
                    fatalError("base62 conversion \(self): index out of range")
                }
                return character
            }
        return String(characters)
    }

    private static func convert(bytes: [UInt8], fromBase sourceBase: Int, toBase targetBase: Int)
        -> [UInt8]
    {
        let bytesCount = bytes.count

        var target: [UInt8] = []

        var source = bytes

        while !source.isEmpty {
            var quotient: [UInt8] = []
            quotient.reserveCapacity(bytesCount)

            var remainder = 0

            for byte in source {
                let accumulator = Int(byte) + remainder * sourceBase
                let digit = UInt8((accumulator - (accumulator % targetBase)) / targetBase)
                remainder = accumulator % targetBase
                if !quotient.isEmpty || digit > 0 {
                    quotient.append(digit)
                }
            }

            if !quotient.isEmpty || remainder > 0 {
                target.append(UInt8(remainder))
            }

            source = quotient
        }

        // pad target with zeroes corresponding to the number of leading zeroes in the source
        for byte in bytes {
            guard byte == 0 else {
                break
            }
            target.append(0)
        }

        return target.reversed()
    }

}

// 86d5c52d-e7bf-452a-ac0b-064f65f821e8 -> 46QfEaPfUXMcvlP4dPgQJ6
// 0000c52d-e7bf-452a-ac0b-064f65f821e8 -> Lp4i5fOQ8Rlp9Ajg5SC
//
// let uuid = UUID(uuidString: "0000c52d-e7bf-452a-ac0b-064f65f821e8")
// if let uuid = uuid {
//    if let s = uuid.base62String {
//         let u = UUID(base62String: s)
//    }
// }
