import Domain

import Vapor
import Fluent
import FluentMySQL

/// This extension conforms the user settings to be usable with Fluent MySQL.
extension UserSettings: MySQLType, ReflectionDecodable {

    /// The type of the database field will be of LONGTEXT.
    public static var mysqlDataType: MySQLDataType {
        return .json
    }

    /// Convert to JSON and store into the database.
    public func convertToMySQLData() -> MySQLData {
        return MySQLData(json: self)
    }

    /// Read JSON from the database.
    public static func convertFromMySQLData(_ data: MySQLData) throws -> UserSettings {
        // convert data to json, return default settings if no value
        do {
            return try data.json(UserSettings.self) ?? UserSettings()
        }
        catch is DecodingError {
            // better return default settings than run into an error
            return UserSettings()
        }
    }

    /// This is needed for fluent. It's necessary to return two arbitrary but distinct values.
    /// I don't know what this does and how this works.
    public static func reflectDecoded() throws -> (UserSettings, UserSettings) {
        var userSettings = UserSettings()
        userSettings.notifications.pushoverEnabled = true
        return (UserSettings(), userSettings)
    }

}
