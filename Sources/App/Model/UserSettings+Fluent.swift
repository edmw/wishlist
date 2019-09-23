import Vapor
import Fluent
import FluentMySQL

/// This extension conforms the user settings to be usable with Fluent MySQL.
extension UserSettings: MySQLType, ReflectionDecodable {

    /// The type of the database field will be of LONGTEXT.
    static var mysqlDataType: MySQLDataType {
        return .json
    }

    /// Convert to JSON and store into the database.
    func convertToMySQLData() -> MySQLData {
        return MySQLData(json: self)
    }

    /// Read JSON from the database.
    static func convertFromMySQLData(_ data: MySQLData) throws -> UserSettings {
        guard let value = data.data(), !value.isEmpty else {
            // return default settings if no value stored in database
            return UserSettings()
        }
        // convert data to json, return default settings if no value
        return try data.json(UserSettings.self) ?? UserSettings()
    }

    /// This is needed for fluent. It's necessary to return two arbitrary but distinct values.
    /// I don't know what this does and how this works.
    static func reflectDecoded() throws -> (UserSettings, UserSettings) {
        var userSettings = UserSettings()
        userSettings.notificationServices.pushoverEnabled = true
        return (UserSettings(), userSettings)
    }

}
