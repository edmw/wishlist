import Vapor

extension Environment {

    static func get(_ key: EnvironmentKey<String>) -> String? {
        return get(key.string)
    }

    static func get(_ key: EnvironmentKey<Int>) -> Int? {
        guard let value = get(key.string) else {
            return nil
        }
        return Int(value)
    }

    static func get(_ key: EnvironmentKey<URL>) -> URL? {
        guard let value = get(key.string) else {
            return nil
        }
        return URL(string: value)
    }

    static func require(_ key: String) throws -> String {
        return try get(key).value(or:
            VaporError(
                identifier: "MissingEnvVar",
                reason: "Required environment variable `\(key)` missing."
            )
        )
    }

    static func require(_ key: EnvironmentKey<String>) throws -> String {
        return try require(key.string)
    }

    static func require(_ key: EnvironmentKey<Int>) throws -> Int {
        let value = try require(key.string)
        return try Int(value).value(or:
            VaporError(
                identifier: "InvalidEnvVar",
                reason: "Value `\(value)` of environment variable `\(key)` is not a valid Integer."
            )
        )
    }

    static func require(_ key: EnvironmentKey<URL>) throws -> URL {
        let value = try require(key.string)
        return try URL(string: value).value(or:
            VaporError(
                identifier: "InvalidEnvVar",
                reason: "Value `\(value)` of environment variable `\(key)` is not a valid URL."
            )
        )
    }

}

// MARK: -

class EnvironmentKeys {

    fileprivate init() {}

}

// MARK: -

class EnvironmentKey<ValueType>: EnvironmentKeys, CustomStringConvertible {

    var string: String

    init(_ key: String) {
        self.string = key
    }

    // MARK: CustomStringConvertible

    var description: String {
        return string
    }

}

// MARK: -

extension Environment {

    static func requireSiteURL() throws -> URL {
        let siteURL = try require(.siteURL)
        guard siteURL.validate(is: .webAbsolutePathEmpty) else {
            throw VaporError(
                identifier: "InvalidEnvVarSiteURL",
                reason: "`\(siteURL)` from environment is not a valid absolute web URL" +
                    " without path."
            )
        }
        return siteURL
    }

}
