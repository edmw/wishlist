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
    config.add(model: User.self, database: .mysql)
    config.add(migration: AddUserSettings.self, database: .mysql)
    config.add(migration: RenameUserName.self, database: .mysql)
    config.add(migration: RenameSubjectId.self, database: .mysql)
    config.add(migration: AddUserIdentityProvider.self, database: .mysql)
    config.add(model: List.self, database: .mysql)
    config.add(migration: AddListOptions.self, database: .mysql)
    config.add(migration: RenameListName.self, database: .mysql)
    config.add(model: Item.self, database: .mysql)
    config.add(migration: RenameItemName.self, database: .mysql)
    config.add(model: Favorite.self, database: .mysql)
    config.add(model: Reservation.self, database: .mysql)
    config.add(model: Invitation.self, database: .mysql)
}

// MARK: - User

struct AddUserIdentityProvider: MySQLForwardMigration {

    static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        return connection
            .assertFieldMustNotExist(\User.identityProvider) {
                return Database.update(User.self, on: connection) { builder in
                    builder.field(for: \.identityProvider)
                }
                .flatMap {
                    // add provider to existing identifiers
                    // at this point in time there are only two providers 'google' and 'netid'
                    return User.query(on: connection).all().flatMap { users in
                        let updates = users.map { user -> EventLoopFuture<User> in
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
        return connection.assertFieldMustNotExist(\User.identity) {
            return connection
                .raw("ALTER TABLE User CHANGE COLUMN subjectId identity VARCHAR(255) NULL")
                .run()
        }
    }

}

struct RenameUserName: MySQLForwardMigration {

    static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        return connection.assertFieldMustNotExist(\User.fullName) {
            return connection
                .raw("ALTER TABLE User CHANGE COLUMN name fullName VARCHAR(255) NOT NULL")
                .run()
        }
    }

}

struct AddUserSettings: MySQLForwardMigration {

    static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        return connection
            .assertFieldMustNotExist(\User.settings) {
                return Database.update(User.self, on: connection) { builder in
                    builder.field(for: \.settings)
                }
            }
    }

}

struct AddUserNickName: MySQLForwardMigration {

    static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        return Database.update(User.self, on: connection) { builder in
            builder.field(for: \.nickName)
        }
    }

}

struct AddUserConfidant: MySQLForwardMigration {

    static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        return Database.update(User.self, on: connection) { builder in
            builder.field(for: \.confidant)
        }
    }

}

struct AddUserIdentificationIndex: MySQLForwardMigration {

    static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        return Database.update(User.self, on: connection) { builder in
            builder.unique(on: \.identification)
        }
    }

}

// MARK: - List

struct RenameListName: MySQLForwardMigration {

    static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        return connection.assertFieldMustNotExist(\List.title) {
            return connection
                .raw("ALTER TABLE List CHANGE COLUMN name title VARCHAR(255) NOT NULL")
                .run()
        }
    }

}

struct AddListOptions: MySQLForwardMigration {

    static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        return connection.assertFieldMustNotExist(\List.options) {
            return Database.update(List.self, on: connection) { builder in
                builder.field(for: \.options)
            }
        }
    }

}

struct AddListItemsSorting: MySQLForwardMigration {

    static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        return Database.update(List.self, on: connection) { builder in
            builder.field(for: \.itemsSorting)
        }
    }

}

struct RenameListModifiedOnColumn: MySQLForwardMigration {

    static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        return connection
            .raw("ALTER TABLE List CHANGE modifiedOn modifiedAt DATETIME(6) NOT NULL")
            .run()
    }

}

struct RenameListCreatedOnColumn: MySQLForwardMigration {

    static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        return connection
            .raw("ALTER TABLE List CHANGE createdOn createdAt DATETIME(6) NOT NULL")
            .run()
    }

}

struct AddListForeignKeyConstraint: MySQLForwardMigration {

    static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        return Database.update(List.self, on: connection) { builder in
            builder.reference(from: \.userID, to: \User.id, onDelete: .cascade)
        }
    }

}

// MARK: - Item

struct RenameItemName: MySQLForwardMigration {

    static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        return connection.assertFieldMustNotExist(\Item.title) {
            return connection
                .raw("ALTER TABLE Item CHANGE COLUMN name title VARCHAR(255) NOT NULL")
                .run()
        }
    }

}

struct AddItemPreference: MySQLForwardMigration {

    static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        return Database.update(Item.self, on: connection) { builder in
            builder.field(for: \.preference, type: .tinyint, .default(0))
        }
    }

}

struct RenameItemModifiedOnColumn: MySQLForwardMigration {

    static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        return connection
            .raw("ALTER TABLE Item CHANGE modifiedOn modifiedAt DATETIME(6) NOT NULL")
            .run()
    }

}

struct RenameItemCreatedOnColumn: MySQLForwardMigration {

    static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        return connection
            .raw("ALTER TABLE Item CHANGE createdOn createdAt DATETIME(6) NOT NULL")
            .run()
    }

}

struct AddItemForeignKeyConstraint: MySQLForwardMigration {

    static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        return Database.update(Item.self, on: connection) { builder in
            builder.reference(from: \.listID, to: \List.id, onDelete: .cascade)
        }
    }

}

// MARK: - Invitation

struct AddInvitationInvitee: MySQLForwardMigration {

    static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        return Database.update(Invitation.self, on: connection) { builder in
            builder.field(for: \.invitee)
        }
    }

}

// MARK: - Reservation

struct RenameReservationCreatedOnColumn: MySQLForwardMigration {

    static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        return connection
            .raw("ALTER TABLE Reservation CHANGE createdOn createdAt DATETIME(6) NOT NULL")
            .run()
    }

}

struct AddReservationForeignKeyConstraint: MySQLForwardMigration {

    static func prepare(on connection: MySQLConnection) -> EventLoopFuture<Void> {
        return Database.update(Reservation.self, on: connection) { builder in
            builder.reference(from: \.itemID, to: \Item.id, onDelete: .cascade)
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
