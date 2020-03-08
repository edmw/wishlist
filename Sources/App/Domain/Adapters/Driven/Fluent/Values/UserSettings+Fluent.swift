import Domain

import Vapor
import Fluent
import FluentMySQL

extension UserSettings: MySQLType {

    public static var mysqlDataType: MySQLDataType {
        return .json
    }

    public func convertToMySQLData() -> MySQLData {
        return MySQLData(json: self)
    }

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

}
