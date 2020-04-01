# Add status field to Reservation entity

## Status

**accepted**

## Context

At the moment there is no possibility to know if a wish has been received. To be able to remove
or to archive an item it is a precondition that this item is either unreserved or received. It
should not be possible to remove or archive an item if it is reserved by another user.

This decision adds the possibility to find out if a wish has been received.

## Decision

A status field will be added to the Reservation entity with two values at this time. A reservation
can be either `open` or `closed`, where `closed` means the linked item has been received.

The owner of an item will have the option to change the status from `open` to `closed`.

A reservation with status `open` can be edited by the user who reserved the item and by the owner
of the item, while a reservation with status `closed` can not be changed anymore. There may be
some kind of administrative task to change back the status to `closed`.

Then an item can be removed or archived if it either has no reservation linked to it at all or
the linked reservation has a status `closed`.

## Consequences

It is possible to tell if a wish has been received.

There must by additional validation logic and an UI action.

## Alternatives

- Resign from the idea to have knowledge if a wish has been received:
  - Usecases like archive an item will possibly break because a user who reserved an item will
    not be able to edit the reservation after the item has been archived.
- Add a status to the Item entity instead:
  - This has the disadvantage of a possible inconsistent state if an item is marked as received,
    but is missing a link to a reservation.

