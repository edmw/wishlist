@testable import App
import Vapor
import Fluent

import XCTest

protocol EntityTestsSupport {
    associatedtype EntityType: Entity & EntityReflectable & Model

    func entityTestProperties()

}

extension EntityTestsSupport {

    func entityTestProperties() {
        // these are the properties reflected by Vapor on this type (count them)
        let count = try! EntityType.reflectProperties(depth: 0).count
        // this is the collection required by the EntityReflectable protocol
        // should be the same number of properties than Vapor sees
        XCTAssertEqual(EntityType.properties.count, count)
        // now test the name function required by the EntityReflectable protocol
        var names = Set<String>()
        // collect distinct names for properties
        for property in EntityType.properties {
            let name = EntityType.propertyName(forKey: property)
            XCTAssertNotNil(name, "No name for property \(String(describing: property))")
            if let name = name {
                names.insert(name)
            }
        }
        // number of distinct names should be the same than Vapor sees
        XCTAssertEqual(names.count, count)
    }

}
