import Vapor
import Random

import Foundation

struct AuthenticationToken: ControllerParameterValue,
    RawRepresentable,
    ExpressibleByStringLiteral,
    CustomStringConvertible,
    Codable,
    Hashable,
    Equatable
{

    let rawValue: String

    init() throws {
        self.rawValue = try URandom().generateToken()
    }

    init(string: String) {
        self.rawValue = string
    }

    // MARK: - RawRepresentable

    init?(rawValue: String) {
        self.init(string: rawValue)
    }

    // MARK: - ExpressibleByStringLiteral

    init(stringLiteral value: String) {
        rawValue = value
    }

    // MARK: - CustomStringConvertible

    var description: String {
        return rawValue
    }

    // MARK: - Codable

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawValue = try container.decode(String.self)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    // MARK: - ControllerParameterValue

    var stringValue: String {
        return rawValue
    }

}
