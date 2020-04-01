# Actor Guide

An `Actor` implements a set of usecases for a specific partion of the domain. An `Actor` is build from a protocol describing the interfaces to the usescases and the specific implementation for the domain. In principle there can be different implementations for an actor and its usecases but usually there is only one.

```
public protocol UserItemsActor: Actor {
    ...
    func moveItem(
        _ specification: MoveItem.Specification,
        _ boundaries: MoveItem.Boundaries
    ) throws -> EventLoopFuture<MoveItem.Result>
    ...
}
```

```
public final class DomainUserItemsActor: UserItemsActor {
    ...
}
```

## Actions

Every usecase is implemented as `Action` in a separate file and added as an extension to the desired `Actor`. For each action there should exist three inner Structures: one to hold all boundaries necessary for performing the action named  `Boundaries`, one to hold all data which must be provided by the caller of the action named  `Specification` and one to hold all the data given back to the caller after executing the action named `Result`.

```
public struct MoveItem: Action {
    public struct Boundaries: AutoActionBoundaries {
        ...
    }
    public struct Specification: AutoActionSpecification {
        ...
    }
    public struct Result: ActionResult {
        ...
    }
    ...
}
```

The structures `Specification` and `Result` define which are the types at the boundary between the application and the domain layer. While a specification should usually contain entity ids only, a result will typically return representations of the domain layer‘s model. A domain model type should never be used for either the specification or the result of an action.

By conforming the boundaries and the specification to `AutoActionBoundaries` and `AutoActionSpecification` code generation is utilized to generated static factory methods for these strutcures.
 
### Execution

The implementation of the execution for an `Action` should go in a method named `execute` which takes model types for parameters and for return values. The `execute` method can be called from outside the domain layer by using the `Actor` or by other domain methods directly.

```
internal func execute(
    on item: Item,
    in list: List,
    moveTo targetlist: List,
    in boundaries: Boundaries
) throws
    -> EventLoopFuture<(list: List, item: Item)>
{
    ...
```

If called from outside the domain layer the method plugged into the `Actor` must translate the given specification into the corresponding model types.

```
public func moveItem(
    _ specification: MoveItem.Specification,
    _ boundaries: MoveItem.Boundaries
) throws -> EventLoopFuture<MoveItem.Result> {
    ...
    // find item and lists by using the ids from the specification and call execute
    ...
    return try MoveItem(actor: self)
        .execute(on: item, in: list, moveTo: targetlist, in: boundaries)
    ...
}
```

### Authorization

The actor‘s usecase method is responsible to check if a caller is authorized to execute a usecase with the provided specification. The usecase‘s execution method may assume that the provided parameters are permitted.

### Data integrity

The usescase‘s execution method must check for data integrity, either for a single parameter or the relation between several parameters. The actor‘s usecase method may omit checking for data integrity if not done anyway.

### Errors

If an error occurs the usescase‘s execution method should throw errors with as much detail as possible based on the domain‘s model types, while the actor‘s usecase method must translate these detailed errors into more general actor related errors containing representations of the domain layer‘s model.

Note: Errors which should not occur in a regulary operating mode can be passed on unchanged, of course. 

Example:

```
struct CreateInvitationValidationError: CreateInvitationError {
    var user: User
    var error: ValuesError<InvitationValues>
}
```

will be translated into

```
public enum UserInvitationsActorError: Error {
    ...
    case validationError(
        UserRepresentation,
        InvitationRepresentation?,
        ValuesError<InvitationValues>
    )
}
```
