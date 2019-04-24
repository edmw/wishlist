# Structure of a Model Entity

This document describes the structure of a Model Entity for the Wishlist application using the Vapor web framework.

## 1 Entity Declaration

```
final class <EntityName>: Entity, Content
```

## 2 Entity Attributes

```
// id attribute
var id: UUID?
// required data attribute example
var <EntityAttributeName>: <EntityAttributeType>
// optional data attribute example
var <EntityAttributeName>: <EntityAttributeType>?
// relation attribute example
var <RelatedEntityName.toLower>ID: <RelatedEntityName>.ID
```

## 3 Entity Initializer

```
init(
    id: UUID? = nil,
    // required data attributes
    <EntityAttributeName>: <EntityAttributeType>,
    // related entities
    user: User
) throws
```

## 4 Properties for Constraints and Validation

```
// constraint example
static let maximumNumberOf<EntityName> = 1000

// validation example
static let minimumLengthOf<EntityAttributeName> = 4
static let maximumLengthOf<EntityAttributeName> = 100
```

## 5 Conformance to `EntityReflectable`:

This is optional and used for better log messages.

```
extension <EntityName>: EntityReflectable {

    static func propertyName(forKey keyPath: PartialKeyPath<<EntityName>>) -> String? {
        switch keyPath {
        case \<EntityName>.id: return "id"
        // data attribute example
        case \<EntityName>.<EntityAttributeName>: return "<EntityAttributeName>"
        default: return nil
        }
    }

}
```

## 6 Extensions

### Traits

```
extension <EntityName>: <Trait>
```

### General

```
extension <EntityName>: CustomStringConvertible
```

## 7 Extension to `Model`

```
extension <EntityName>: Model {

    typealias Database = MySQLDatabase
    typealias ID = UUID
    static let idKey: IDKey = \.id

    // relation example
    var <RelatedEntityName.toLower>: Parent<<EntityName>, <RelatedEntityName>> {
        return parent(\.<RelatedEntityName.toLower>ID)
    }

}
```

```
extension <EntityName>: Migration {

    static func prepare(on connection: Database.Connection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            builder.field(for: \.id)
            // example data attribute
            builder.field(for: \.<EntityAttributeName>)
            // example data attribute with explicit model type
            builder.field(for: \.<EntityAttributeName>, type: .varchar(255))
            // example relation
            builder.reference(
                from: \.<RelatedEntityName.toLower>ID,
                to: \<RelatedEntityName>.id,
                onDelete: .cascade
            )
        }
    }

}
```

