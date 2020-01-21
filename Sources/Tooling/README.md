#  Code Generation

## Types

Protocols prefixed with 'Auto' enable code generation for conforming types:

### AutoActionBoundaries

SUMMARY: A static factory method will be generated for action boundaries types conforming to `AutoActionBoundaries`.

Boundaries of actions are provided by types conforming to `ActionBoundaries` defining all needed boundary values for an action to be run.

```
// Boundaries for action to create an item.
public struct CreateItem.Boundaries: ActionBoundaries {
    public let worker: EventLoop
    public let imageStore: ImageStoreProvider
}
```

For a clean interface a static factory method named `boundaries` should be provided. Using the static factory method instead of `init` to create a boundaries type allows calls for action in the following manner:

```
try userItemsActor
    .createItem(
        .specification(userBy: userid, listBy: listid, from: data),
        .boundaries(
            worker: request.eventLoop,
            imageStore: VaporImageStoreProvider(on: request)
        )
    )
```

### AutoActionSpecification

SUMMARY: A static factory method will be generated for action specification types conforming to `AutoActionSpecification`.

Specifications for actions are provided by types conforming to `ActionSpecification` defining all needed specification values for an action to be run.

```
// Specification for action to update a list.
public struct Specification: AutoActionSpecification {
    public let userID: UserID
    public let listID: ListID
    public let values: ListValues
}
```

For a clean interface a static factory method named `specification` should be provided. Using the static factory method instead of `init` to create a specification type allows calls for action in the following manner:

```
try userListsActor
    .updateList(
        .specification(userBy: userid, listBy: listid, from: data),
        .boundaries(
            worker: request.eventLoop
        )
    )
```
