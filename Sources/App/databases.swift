///////////////////////////////////////////////////////////////////////////////////////////////////
// Wishlist - databases
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
import Fluent
import FluentMySQL

func databases(
    config: inout DatabasesConfig,
    siteConfig: inout Site,
    environment: inout Environment,
    logger: BasicLogger? = nil
) throws {
    let mysqlConfig = MySQLDatabaseConfig(
        hostname: Environment.get(.dbHost) ?? "localhost",
        port: Environment.get(.dbPort) ?? 3_306,
        username: Environment.get(.dbUsername) ?? "wishlist",
        password: Environment.get(.dbPassword) ?? "wishlist",
        database: Environment.get(.dbName) ?? "wishlist"
    )
    config.add(database: MySQLDatabase(config: mysqlConfig), as: .mysql)
    if !environment.isRelease && .verbose == logger?.logLevel ?? .verbose {
        config.enableLogging(on: .mysql)
    }
}

extension EnvironmentKeys {
    static let dbHost = EnvironmentKey<String>("DBHOST")
    static let dbPort = EnvironmentKey<Int>("DBPORT")
    static let dbUsername = EnvironmentKey<String>("DBUSERNAME")
    static let dbPassword = EnvironmentKey<String>("DBPASSWORD")
    static let dbName = EnvironmentKey<String>("DBNAME")
}
