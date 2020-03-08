@testable import Domain
import Foundation
import NIO

import XCTest
import Testing

struct TestEntity: Entity, EntityReflectable {

    var id: UUID?
    var string: String
    var int: Int

    public static var properties: EntityProperties<TestEntity> = .build(
        .init(\TestEntity.id, label: "id"),
        .init(\TestEntity.string, label: "string"),
        .init(\TestEntity.int, label: "int")
    )

}

final class EntityTests: XCTestCase, DomainTestCase, HasAllTests {

    static var __allTests = [
        ("testEntityEquatable", testEntityEquatable),
        ("testEntityHashable", testEntityHashable),
        ("testAllTests", testAllTests)
    ]

    func testEntityEquatable() throws {
        let uuid = UUID()
        let entity1 = TestEntity(id: uuid, string: "hi there", int: 17)
        let entity2 = TestEntity(id: uuid, string: "hi there", int: 17)
        let entity3 = TestEntity(id: UUID(), string: "hi there and here", int: 25)
        XCTAssertEqual(entity1, entity2)
        XCTAssertNotEqual(entity1, entity3)
        XCTAssertNotEqual(entity2, entity3)

        let keypath = EntityKeyPath(\TestEntity.string, label: "string")
        XCTAssertTrue(keypath.isEqual(entity1, entity2))
        XCTAssertFalse(keypath.isEqual(entity1, entity3))
        XCTAssertFalse(keypath.isEqual(entity2, entity3))
        
        let entity4 = TestEntity(id: uuid, string: "hi there and here", int: 17)
        XCTAssertTrue(
            EntityKeyPath(\TestEntity.id, label: "id").isEqual(entity1, entity4)
        )
        XCTAssertFalse(
            EntityKeyPath(\TestEntity.string, label: "string").isEqual(entity1, entity4)
        )
        XCTAssertTrue(
            EntityKeyPath(\TestEntity.int, label: "int").isEqual(entity1, entity4)
        )
    }

    func testEntityHashable() throws {
        let entity = TestEntity(id: UUID(), string: "hi there", int: 17)

        var entityHasher = Hasher()
        var valuesHasher = entityHasher
        // hash by using entities‘ hash function
        entity.hash(into: &entityHasher)
        let entityHash = entityHasher.finalize()
        // hash by using entities‘ property values
        valuesHasher.combine(entity.id)
        valuesHasher.combine(entity.string)
        valuesHasher.combine(entity.int)
        let valuesHash = valuesHasher.finalize()
        XCTAssertEqual(entityHash, valuesHash)

        // hash by using keypath
        let keypath = EntityKeyPath(\TestEntity.string, label: "string")
        var keypathHasher = Hasher()
        keypath.combine(entity, into: &keypathHasher)
        // hash by using property value
        var propertyHasher = Hasher()
        propertyHasher.combine(entity.string)
        XCTAssertEqual(keypathHasher.finalize(), propertyHasher.finalize())
    }

    func testAllTests() throws {
        assertAllTests()
    }

}
