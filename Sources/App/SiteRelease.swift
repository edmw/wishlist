///////////////////////////////////////////////////////////////////////////////////////////////////
// Wishlist - Site release
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

import Vapor

import Foundation

enum SiteRelease: String, Codable, CaseIterable {

    case alpha
    case beta
    case gold

    init?(string: String) {
        self.init(rawValue: string)
    }

}

// MARK: -

extension Environment {

    static func get(_ key: EnvironmentKey<SiteRelease>) -> SiteRelease? {
        guard let value = get(key.string) else {
            return nil
        }
        return SiteRelease(string: value)
    }

    static func require(_ key: EnvironmentKey<SiteRelease>) throws -> SiteRelease {
        let value = try require(key.string)
        return try SiteRelease(string: value).value(or:
            VaporError(
                identifier: "InvalidEnvVar",
                reason: "Value `\(value)` of environment variable `\(key)`" +
                    " is not a valid release setting."
            )
        )
    }

}
