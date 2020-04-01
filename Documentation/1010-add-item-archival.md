# Add archival field to Item entity

## Status

**accepted**

## Context

At the moment there is no possibility for a user to hide an item from a wishlist without deleting it. To be able to
hide an item and bring it back again later, this decision adds a flag to items which indicates if an item is
considered to be archived or not. Archived items won‘t be displayed on a wishlist.

## Decision

An archival field of type boolean will be added to the Item entity. `True` indicates the item is to be considered
as archived.

The owner of an item will have the option to change the value of the flag. An item can be archived at any time,
except if the item is reserved but not received. This prevents an item from disappearing from a wishlist, while
it may be in transition into status received. If the owner unarchives an item, the item will revert to its exact
state as it was before.

## Consequences

It is possible to tell if a wish is in the archive. Archived wishes won't be available for a user of a wishlist.

There must by additional validation logic and an UI action for archiving an wish and another UI action for
unarchiving a wish.

## Alternatives

None
