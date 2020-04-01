///////////////////////////////////////////////////////////////////////////////////////////////////
// Wishlist - databases migrations
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
// swiftlint:disable file_length

import Domain

import Vapor
import Fluent
import FluentMySQL

func databasesMigrations(
    config: inout MigrationConfig,
    siteConfig: inout Site,
    environment: inout Environment,
    logger: Logger? = nil
) throws {
    // User
    config.add(model: FluentUser.self, database: .mysql)
    // List
    config.add(model: FluentList.self, database: .mysql)
    // Item
    config.add(model: FluentItem.self, database: .mysql)
    config.add(migration: AddItemArchival.self, database: .mysql)
    // Favorite
    config.add(model: FluentFavorite.self, database: .mysql)
    // Reservation
    config.add(model: FluentReservation.self, database: .mysql)
    config.add(migration: AddReservationStatus.self, database: .mysql)
    // Invitation
    config.add(model: FluentInvitation.self, database: .mysql)
}

// MARK: - User

struct ModifyUserLanguage: MySQLForwardMigration {

    static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        return connection
            .raw("ALTER TABLE User MODIFY language VARCHAR(64) NULL")
            .run()
    }

}

struct AddUserIdentityProvider: MySQLForwardMigration {

    static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        return connection
            .assertFieldMustNotExist(\FluentUser.identityProvider) {
                return Database.update(FluentUser.self, on: connection) { builder in
                    builder.field(for: \.identityProvider)
                }
                .flatMap {
                    // add provider to existing identifiers
                    // at this point in time there are only two providers 'google' and 'netid'
                    return FluentUser.query(on: connection).all().flatMap { users in
                        let updates = users.map { model -> EventLoopFuture<FluentUser> in
                            var user = model
                            guard let identity = user.identity else {
                                return connection.future(user)
                            }
                            if identity.hasLetters || identity.count > 24 {
                                // netid identites are alphanumeric and longer than google identites
                                user.identityProvider
                                    = UserIdentityProvider(NetIDAuthenticationUserInfo.provider)
                            }
                            else {
                                // google (by default)
                                user.identityProvider
                                    = UserIdentityProvider(GoogleAuthenticationUserInfo.provider)
                            }
                            return user.save(on: connection)
                        }
                        return EventLoopFuture.andAll(updates, eventLoop: connection.eventLoop)
                    }
                }
            }
    }

}

struct RenameSubjectId: MySQLForwardMigration {

    static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        return connection.assertFieldMustNotExist(\FluentUser.identity) {
            return connection
                .raw("ALTER TABLE User CHANGE COLUMN subjectId identity VARCHAR(255) NULL")
                .run()
        }
    }

}

struct RenameUserName: MySQLForwardMigration {

    static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        return connection.assertFieldMustNotExist(\FluentUser.fullName) {
            return connection
                .raw("ALTER TABLE User CHANGE COLUMN name fullName VARCHAR(255) NOT NULL")
                .run()
        }
    }

}

struct AddUserSettings: MySQLForwardMigration {

    static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        return connection
            .assertFieldMustNotExist(\FluentUser.settings) {
                return Database.update(FluentUser.self, on: connection) { builder in
                    builder.field(for: \.settings)
                }
            }
    }

}

struct AddUserNickName: MySQLForwardMigration {

    static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        return Database.update(FluentUser.self, on: connection) { builder in
            builder.field(for: \.nickName)
        }
    }

}

struct AddUserConfidant: MySQLForwardMigration {

    static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        return Database.update(FluentUser.self, on: connection) { builder in
            builder.field(for: \.confidant)
        }
    }

}

struct AddUserIdentificationIndex: MySQLForwardMigration {

    static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        return Database.update(FluentUser.self, on: connection) { builder in
            builder.unique(on: \.identification)
        }
    }

}

// MARK: - List

struct ModifyListTitle: MySQLForwardMigration {

    static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        return connection
            .raw("ALTER TABLE List MODIFY title VARCHAR(2000) NOT NULL")
            .run()
    }

}

struct RenameListName: MySQLForwardMigration {

    static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        return connection.assertFieldMustNotExist(\FluentList.title) {
            return connection
                .raw("ALTER TABLE List CHANGE COLUMN name title VARCHAR(255) NOT NULL")
                .run()
        }
    }

}

struct AddListOptions: MySQLForwardMigration {

    static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        return connection.assertFieldMustNotExist(\FluentList.options) {
            return Database.update(FluentList.self, on: connection) { builder in
                builder.field(for: \.options)
            }
        }
    }

}

struct AddListItemsSorting: MySQLForwardMigration {

    static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        return Database.update(FluentList.self, on: connection) { builder in
            builder.field(for: \.itemsSorting)
        }
    }

}

struct RenameListModifiedOn: MySQLForwardMigration {

    static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        return connection
            .raw("ALTER TABLE List CHANGE modifiedOn modifiedAt DATETIME(6) NOT NULL")
            .run()
    }

}

struct RenameListCreatedOn: MySQLForwardMigration {

    static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        return connection
            .raw("ALTER TABLE List CHANGE createdOn createdAt DATETIME(6) NOT NULL")
            .run()
    }

}

struct AddListForeignKeyConstraint: MySQLForwardMigration {

    static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        return Database.update(FluentList.self, on: connection) { builder in
            builder.reference(from: \.userKey, to: \FluentUser.uuid, onDelete: .cascade)
        }
    }

}

// MARK: - Item

struct AddItemArchival: MySQLForwardMigration {

    static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        return connection.assertFieldMustNotExist(\FluentItem.archival) {
            return Database.update(FluentItem.self, on: connection) { builder in
                builder.field(for: \.archival)
            }
        }
    }

}

struct ModifyItemTitle: MySQLForwardMigration {

    static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        return connection
            .raw("ALTER TABLE Item MODIFY title VARCHAR(2000) NOT NULL")
            .run()
    }

}

struct RenameItemName: MySQLForwardMigration {

    static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        return connection.assertFieldMustNotExist(\FluentItem.title) {
            return connection
                .raw("ALTER TABLE Item CHANGE COLUMN name title VARCHAR(255) NOT NULL")
                .run()
        }
    }

}

struct AddItemPreference: MySQLForwardMigration {

    static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        return Database.update(FluentItem.self, on: connection) { builder in
            builder.field(for: \.preference, type: .tinyint, .default(0))
        }
    }

}

struct RenameItemModifiedOn: MySQLForwardMigration {

    static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        return connection
            .raw("ALTER TABLE Item CHANGE modifiedOn modifiedAt DATETIME(6) NOT NULL")
            .run()
    }

}

struct RenameItemCreatedOn: MySQLForwardMigration {

    static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        return connection
            .raw("ALTER TABLE Item CHANGE createdOn createdAt DATETIME(6) NOT NULL")
            .run()
    }

}

struct AddItemForeignKeyConstraint: MySQLForwardMigration {

    static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        return Database.update(FluentItem.self, on: connection) { builder in
            builder.reference(from: \.listKey, to: \FluentList.uuid, onDelete: .cascade)
        }
    }

}

// MARK: - Favorite

struct RenameFavoriteTable: MySQLForwardMigration {

    static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        return connection.assertTableMustNotExist(FluentFavorite.self) {
            return connection
                .raw("RENAME TABLE List_User TO Favorite")
                .run()
        }
    }

}

// MARK: - Invitation

struct RenameInvitationInvitee: MySQLForwardMigration {

    static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        return connection.assertFieldMustNotExist(\FluentInvitation.inviteeKey) {
            return connection
                .raw("ALTER TABLE Invitation CHANGE invitee inviteeID VARBINARY(16) NULL")
                .run()
        }
    }

}

struct AddInvitationInvitee: MySQLForwardMigration {

    static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        return Database.update(FluentInvitation.self, on: connection) { builder in
            builder.field(for: \.inviteeID)
        }
    }

}

// MARK: - Reservation

struct RenameReservationCreatedOn: MySQLForwardMigration {

    static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        return connection
            .raw("ALTER TABLE Reservation CHANGE createdOn createdAt DATETIME(6) NOT NULL")
            .run()
    }

}

struct AddReservationForeignKeyConstraint: MySQLForwardMigration {

    static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        return Database.update(FluentReservation.self, on: connection) { builder in
            builder.reference(from: \.itemKey, to: \FluentItem.uuid, onDelete: .cascade)
        }
    }

}

struct AddReservationStatus: MySQLForwardMigration {

    static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        return connection
            .assertFieldMustNotExist(\FluentReservation.status) {
                return Database.update(FluentReservation.self, on: connection) { builder in
                    builder.field(
                        for: \.status,
                        type: Reservation.Status.mysqlDataType,
                        .default(.literal(0))
                    )
                }
            }
    }

}

// MARK: - MySQLMigration Extension

/// Migration with an default revert function which does nothing.
protocol MySQLForwardMigration: MySQLMigration {
}

extension MySQLForwardMigration {

    static func revert(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        return connection.future(())
    }

}

// MARK: - MySQLConnection Extension

extension MySQLConnection {

    /// Executes the given closure only when the specified table does not exist.
    func assertTableMustNotExist<R: Model>(
        _ model: R.Type,
        closure: @escaping () throws -> EventLoopFuture<Void>
    ) -> EventLoopFuture<Void> where R.Database == MySQLDatabase {
        let table = R.self.entity
        return self
            .raw("SELECT 1 FROM `\(table)` LIMIT 1;")
            .first()
            .flatMap { _ in
                return self.future(())
            }
            .catchFlatMap { error in
                guard error is MySQLError else {
                    throw error
                }
                return try closure()
            }
    }

    /// Executes the given closure only when the specified field does not exist.
    func assertFieldMustNotExist<R: Model, V>(
        _ keypath: KeyPath<R, V>,
        closure: @escaping () throws -> EventLoopFuture<Void>
    ) -> EventLoopFuture<Void> where R.Database == MySQLDatabase {
        let table = R.self.entity
        let column = R.self.Database.queryField(.keyPath(keypath))
        return self
            .raw("SHOW COLUMNS FROM `\(table)` LIKE '\(column.identifier.string)';")
            .first()
            .flatMap { column in
                guard column == nil else {
                    return self.future(())
                }
                return try closure()
            }
    }

}
