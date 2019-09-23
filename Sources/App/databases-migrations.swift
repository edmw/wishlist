///////////////////////////////////////////////////////////////////////////////////////////////////
// Wishlist - databases migrations
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

func databasesMigrations(
    config: inout MigrationConfig,
    siteConfig: inout Site,
    environment: inout Environment,
    logger: Logger? = nil
) throws {
    config.add(model: User.self, database: .mysql)
    config.add(migration: AddUserSettings.self, database: .mysql)
    config.add(migration: RenameUserName.self, database: .mysql)
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

struct RenameUserName: MySQLMigration {

    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return connection
            .raw("ALTER TABLE User CHANGE COLUMN name fullName VARCHAR(255) NOT NULL")
            .run()
    }

    static func revert(on connection: MySQLConnection) -> Future<Void> {
        return connection
            .raw("ALTER TABLE User CHANGE COLUMN fullName name VARCHAR(255) NOT NULL")
            .run()
    }

}

struct AddUserSettings: MySQLMigration {

    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.update(User.self, on: connection) { builder in
            builder.field(for: \.settings)
        }
    }

    static func revert(on connection: MySQLConnection) -> Future<Void> {
        return Database.update(User.self, on: connection) { builder in
            builder.deleteField(for: \.settings)
        }
    }

}

struct AddUserNickName: MySQLMigration {

    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.update(User.self, on: connection) { builder in
            builder.field(for: \.nickName)
        }
    }

    static func revert(on connection: MySQLConnection) -> Future<Void> {
        return Database.update(User.self, on: connection) { builder in
            builder.deleteField(for: \.nickName)
        }
    }

}

struct AddUserConfidant: MySQLMigration {

    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.update(User.self, on: connection) { builder in
            builder.field(for: \.confidant)
        }
    }

    static func revert(on connection: MySQLConnection) -> Future<Void> {
        return Database.update(User.self, on: connection) { builder in
            builder.deleteField(for: \.confidant)
        }
    }

}

struct AddUserIdentificationIndex: MySQLMigration {

    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.update(User.self, on: connection) { builder in
            builder.unique(on: \.identification)
        }
    }

    static func revert(on connection: MySQLConnection) -> Future<Void> {
        return Database.update(User.self, on: connection) { builder in
            builder.deleteUnique(from: \.identification)
        }
    }

}

// MARK: - List

struct RenameListName: MySQLMigration {

    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return connection
            .raw("ALTER TABLE List CHANGE COLUMN name title VARCHAR(255) NOT NULL")
            .run()
    }

    static func revert(on connection: MySQLConnection) -> Future<Void> {
        return connection
            .raw("ALTER TABLE List CHANGE COLUMN title name VARCHAR(255) NOT NULL")
            .run()
    }

}

struct AddListOptions: MySQLMigration {

    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.update(List.self, on: connection) { builder in
            builder.field(for: \.options)
        }
    }

    static func revert(on connection: MySQLConnection) -> Future<Void> {
        return Database.update(List.self, on: connection) { builder in
            builder.deleteField(for: \.options)
        }
    }

}

struct AddListItemsSorting: MySQLMigration {

    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.update(List.self, on: connection) { builder in
            builder.field(for: \.itemsSorting)
        }
    }

    static func revert(on connection: MySQLConnection) -> Future<Void> {
        return Database.update(List.self, on: connection) { builder in
            builder.deleteField(for: \.itemsSorting)
        }
    }

}

struct RenameListModifiedOnColumn: MySQLMigration {

    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return connection
            .raw("ALTER TABLE List CHANGE modifiedOn modifiedAt DATETIME(6) NOT NULL")
            .run()
    }

    static func revert(on connection: MySQLConnection) -> Future<Void> {
        return connection
            .raw("ALTER TABLE List CHANGE modifiedAt modifiedOn DATETIME(6) NOT NULL")
            .run()
    }

}

struct RenameListCreatedOnColumn: MySQLMigration {

    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return connection
            .raw("ALTER TABLE List CHANGE createdOn createdAt DATETIME(6) NOT NULL")
            .run()
    }

    static func revert(on connection: MySQLConnection) -> Future<Void> {
        return connection
            .raw("ALTER TABLE List CHANGE createdAt createdOn DATETIME(6) NOT NULL")
            .run()
    }

}

struct AddListForeignKeyConstraint: MySQLMigration {

    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.update(List.self, on: connection) { builder in
            builder.reference(from: \.userID, to: \User.id, onDelete: .cascade)
        }
    }

    static func revert(on connection: MySQLConnection) -> Future<Void> {
        return Database.update(List.self, on: connection) { builder in
            builder.deleteReference(from: \.userID, to: \User.id)
        }
    }

}

// MARK: - Item

struct RenameItemName: MySQLMigration {

    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return connection
            .raw("ALTER TABLE Item CHANGE COLUMN name title VARCHAR(255) NOT NULL")
            .run()
    }

    static func revert(on connection: MySQLConnection) -> Future<Void> {
        return connection
            .raw("ALTER TABLE Item CHANGE COLUMN title name VARCHAR(255) NOT NULL")
            .run()
    }

}

struct AddItemPreference: MySQLMigration {

    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.update(Item.self, on: connection) { builder in
            builder.field(for: \.preference, type: .tinyint, .default(0))
        }
    }

    static func revert(on connection: MySQLConnection) -> Future<Void> {
        return Database.update(Item.self, on: connection) { builder in
            builder.deleteField(for: \.preference)
        }
    }

}

struct RenameItemModifiedOnColumn: MySQLMigration {

    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return connection
            .raw("ALTER TABLE Item CHANGE modifiedOn modifiedAt DATETIME(6) NOT NULL")
            .run()
    }

    static func revert(on connection: MySQLConnection) -> Future<Void> {
        return connection
            .raw("ALTER TABLE Item CHANGE modifiedAt modifiedOn DATETIME(6) NOT NULL")
            .run()
    }

}

struct RenameItemCreatedOnColumn: MySQLMigration {

    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return connection
            .raw("ALTER TABLE Item CHANGE createdOn createdAt DATETIME(6) NOT NULL")
            .run()
    }

    static func revert(on connection: MySQLConnection) -> Future<Void> {
        return connection
            .raw("ALTER TABLE Item CHANGE createdAt createdOn DATETIME(6) NOT NULL")
            .run()
    }

}

struct AddItemForeignKeyConstraint: MySQLMigration {

    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.update(Item.self, on: connection) { builder in
            builder.reference(from: \.listID, to: \List.id, onDelete: .cascade)
        }
    }

    static func revert(on connection: MySQLConnection) -> Future<Void> {
        return Database.update(Item.self, on: connection) { builder in
            builder.deleteReference(from: \.listID, to: \List.id)
        }
    }

}

// MARK: - Invitation

struct AddInvitationInvitee: MySQLMigration {

    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.update(Invitation.self, on: connection) { builder in
            builder.field(for: \.invitee)
        }
    }

    static func revert(on connection: MySQLConnection) -> Future<Void> {
        return Database.update(Invitation.self, on: connection) { builder in
            builder.deleteField(for: \.invitee)
        }
    }

}

// MARK: - Reservation

struct RenameReservationCreatedOnColumn: MySQLMigration {

    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return connection
            .raw("ALTER TABLE Reservation CHANGE createdOn createdAt DATETIME(6) NOT NULL")
            .run()
    }

    static func revert(on connection: MySQLConnection) -> Future<Void> {
        return connection
            .raw("ALTER TABLE Reservation CHANGE createdAt createdOn DATETIME(6) NOT NULL")
            .run()
    }

}

struct AddReservationForeignKeyConstraint: MySQLMigration {

    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.update(Reservation.self, on: connection) { builder in
            builder.reference(from: \.itemID, to: \Item.id, onDelete: .cascade)
        }
    }

    static func revert(on connection: MySQLConnection) -> Future<Void> {
        return Database.update(Reservation.self, on: connection) { builder in
            builder.deleteReference(from: \.itemID, to: \Item.id)
        }
    }

}
