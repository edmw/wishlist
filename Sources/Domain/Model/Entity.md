# Structure of a Model Entity

This document describes the structure of a Model Entity for the Wishlist application.

## 1 Entity Declaration

```
final class <EntityName>: Entity
```

## 2 Entity Attributes

```
// id attribute (value object type)
var id: <EntityName>ID?
// required data attribute example
var <EntityAttributeName>: <EntityAttributeType>
// optional data attribute example
var <EntityAttributeName>: <EntityAttributeType>?
// relation attribute example
var <RelatedEntityName.toLower>ID: <RelatedEntityName>ID
```

## 3 Entity Initializer

```
init(
    id: <EntityName>ID? = nil,
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

## 5 Conformance to `EntityDetachable`:

This adds a `detach` method which can be used to modify the entity after it has been deleted from its repository to reflect it’s not attached to any persistence anymore.

## 6 Conformance to `EntityReflectable`:

This is optional and adds support of mapping key paths to readable strings to the entity. This can be used for better error or log messages.

```
extension <EntityName>: EntityReflectable {

    public static var properties: EntityProperties<Invitation> = .build(
        .init(\<EntityName>.id, label: "id"),
        .init(\<EntityName>.<EntityAttributeName>, label: "<EntityAttributeName>"),
        ...
    )

}
```

## 7 Conformance to `Loggable`:

This add support for providing different encodable views to Self for structured logging. By default returns `description` for the default encodable and `self` for the debugging encodable.

## 8 Extensions

### Traits

```
extension <EntityName>: <Trait>
```

### General

```
extension <EntityName>: CustomStringConvertible
```
