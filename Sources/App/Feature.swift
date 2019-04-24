///////////////////////////////////////////////////////////////////////////////////////////////////
// Wishlist - Feature
//
// Copyright (c) 2019 Michael Baumgärtner
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
import SwiftDate

enum Feature: Codable, Equatable, Comparable, CustomStringConvertible {

    case inPlanning(Priority)
    case inDevelopment(Bool)
    case inProduction(DateInRegion, Version)

    var enabled: Bool {
        switch self {
        case .inPlanning:
            return false
        case .inDevelopment(let enabled):
            return enabled
        case .inProduction:
            return true
        }
    }

    init(date: String, version: Version) {
        guard let date = date.toDate() else {
            fatalError("Invalid date for feature!")
        }
        self = .inProduction(date, version)
    }

    // MARK: Equatable

    static func == (lhs: Feature, rhs: Feature) -> Bool {
        switch (lhs, rhs) {
        case let(.inPlanning(lhs), .inPlanning(rhs)):
            return lhs == rhs
        case let(.inDevelopment(lhs), .inDevelopment(rhs)):
            return lhs == rhs
        case let(.inProduction(lhs1, lhs2), .inProduction(rhs1, rhs2)):
            return lhs1 == rhs1 && lhs2 == rhs2
        default:
            return false
        }
    }

    // MARK: Comparable

    static func < (lhs: Feature, rhs: Feature) -> Bool {
        switch (lhs, rhs) {
        case (.inPlanning, .inDevelopment):
            return true
        case (.inPlanning, .inProduction):
            return true
        case (.inProduction, .inDevelopment):
            return true
        case let(.inPlanning(lhs), .inPlanning(rhs)):
            return lhs < rhs
        case let(.inProduction(lhs, _), .inProduction(rhs, _)):
            return lhs < rhs
        default:
            return false
        }
    }

    // MARK: CustomStringConvertible

    var description: String {
        switch self {
        case let(.inPlanning(priority)):
            return "\(enabled) (in planning with priority \(priority))"
        case let(.inDevelopment(enabled)):
            return "\(enabled) (in development)"
        case let(.inProduction(date, version)):
            return "\(enabled) (in production since \(date.toFormat("yyyy-MM-dd"))" +
            " for version \(version))"
        }
    }

    // MARK: Codable

    private enum CodingKeys: String, CodingKey {
        case base
        case enabled
        case planningValues
        case developmentValues
        case productionValues
    }

    private enum Base: String, Codable {
        case inPlanning
        case inDevelopment
        case inProduction
    }

    private struct PlanningValues: Codable {
        let priority: Priority
    }

    private struct DevelopmentValues: Codable {
        let enabled: Bool
    }

    private struct ProductionValues: Codable {
        let date: DateInRegion
        let version: Version
    }

    enum FeatureCodingError: Error {
        case decoding(String)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let(.inPlanning(priority)):
            try container.encode(Base.inPlanning, forKey: .base)
            try container.encode(
                PlanningValues(priority: priority),
                forKey: .planningValues
            )
        case let(.inDevelopment(enabled)):
            try container.encode(Base.inDevelopment, forKey: .base)
            try container.encode(
                DevelopmentValues(enabled: enabled),
                forKey: .developmentValues
            )
        case let(.inProduction(date, version)):
            try container.encode(Base.inProduction, forKey: .base)
            try container.encode(
                ProductionValues(date: date, version: version),
                forKey: .productionValues
            )
        }
        try container.encode(enabled, forKey: .enabled)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let base = try container.decode(Base.self, forKey: .base)

        switch base {
        case .inPlanning:
            let values = try container.decode(
                PlanningValues.self,
                forKey: .planningValues
            )
            self = .inPlanning(values.priority)
        case .inDevelopment:
            let values = try container.decode(
                DevelopmentValues.self,
                forKey: .developmentValues
            )
            self = .inDevelopment(values.enabled)
        case .inProduction:
            let values = try container.decode(
                ProductionValues.self,
                forKey: .productionValues
            )
            self = .inProduction(values.date, values.version)
        }
    }

}

// MARK: -

enum Priority: Int, Equatable, Comparable, Codable {

    case low = 0
    case normal = 50
    case high = 100

    // MARK: Comparable

    static func < (lhs: Priority, rhs: Priority) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }

}

// MARK: -

struct Version: Codable, Equatable, ExpressibleByStringLiteral, CustomStringConvertible {

    let string: String

    // MARK: Codable

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        string = try container.decode(String.self)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(string)
    }

    // MARK: ExpressibleByStringLiteral

    init(stringLiteral value: String) {
        string = value
    }

    // MARK: CustomStringConvertible

    var description: String {
        return string
    }

}
