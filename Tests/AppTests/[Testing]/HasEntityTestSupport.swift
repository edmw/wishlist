@testable import Domain
import Vapor
import Fluent

import XCTest
import Testing

protocol HasEntityTestSupport {
    associatedtype EntityType: Entity & EntityReflectable
    associatedtype ModelType: Model

    func entityTestProperties()

}

extension HasEntityTestSupport {

    /// This test works in the AppTest target only, because it uses Vapor‘s reflection
    /// mechanism to count the properties on a model entity and matches it to the number
    /// of declared properties.
    func entityTestProperties() {
        // these are the properties reflected by Vapor on this type (count them)
        let count = try! ModelType.reflectProperties(depth: 0).count
        // this is the collection required by the EntityReflectable protocol
        // should be the same number of properties than Vapor sees
        XCTAssertEqual(EntityType.properties.count, count)
        // now test the name function required by the EntityReflectable protocol
        var labels = Set<String>()
        // collect distinct names for properties
        for property in EntityType.properties {
            labels.insert(property.label)
        }
        // number of distinct names should be the same than Vapor sees
        XCTAssertEqual(labels.count, count)
    }

}
