# Changelog

- 🖌 flags a functional feature
- 🛠️ flags a technical feature
- ☘ flags a fix

## [1.6.0]
- 🖌 Add functionality to put items into archive
- 🖌 Add functionality to get items from archive
- 🖌 Add functionality to mark items as received
- 🛠️ Add status field to Reservation
- 🛠️ Add archival field to Item
- 🛠️ Extract english texts into language file
- 🛠️ Extend PageContext to hold actions aka links for templates
- 🛠️ Unify page generation in controller
- 🛠️ Improve button design
- 🛠️ Setup Travis CI

## [1.5.0]
- 🖌 Add functionality to move items between wishlists
- 🛠️ Change handling of .env files: already existing env values will have precedence
- 🛠️ Enable test runs for Linux
- 🛠️ Add automatic generation of LinuxMain.swift
- 🛠️ Improve docker scripts
- ☘ Fix references on fluent models (again)
- ☘ Fix recover job
- ☘ Fix Environment tests

## [1.4.3]
- 🛠️ Improve docker scripts
- 🛠️ Add job to recover missing item images
- 🛠️ Add job to dispose redundant item images
- ☘ Fix creation of item image

## [1.4.2]
- 🛠️ Add Swift Backtrace to automatically printing crash backtraces
- 🛠️ Add code generation for Representation Context types
- 🛠️ Add code generation for Domain String Value types on Linux
- 🛠️ Refactor Values types
- ☘ Fix references on fluent models
- ☘ Fix sort order of items
- ☘ Fix lost data at list import
- ☘ Fix closures for converting in Values types on Linux

## [1.4.1]
- 🛠️ Introduce code generation
- 🛠️ Introduce structured logging
- 🛠️ Add BitArray data structure
- 🛠️ Add BloomFilter data structure
- 🛠️ Add data objects for database repositories
- 🛠️ Make ids for entities into value objects
- 🛠️ Refactor image handling for items
- 🛠️ Improve env file parsing
- 🛠️ Add tests
- ☘ Fix sending invitation mail

## [1.4.0]
- 🖌 Add invitation emails
- 🛠️ Major refactoring to implement separation of concerns
- ☘ Fix link to fav icon
- ☘ Fix deletion of reservation for list owner

```
CLOC before refactoring:

Language                     files          blank        comment           code
-------------------------------------------------------------------------------
Swift                          226           2684           1523          10227

CLOC after refactoring:

Language                     files          blank        comment           code
-------------------------------------------------------------------------------
Swift                          383           4390           2500          16025
```

## [1.3.3]
- 🛠️ Add favicon
- ☘ Fix link to about page

## [1.3.2]
- 🖌 Add pages for legal notice and privacy policy

## [1.3.1]
- ☘ Fix option "Don't spoil my surprises" on lists for notifications

## [1.3.0]
- 🖌 Add settings for user in profile
- 🖌 Add notifications about reservations for list owner
- 🛠️ Add background jobs
- 🛠️ Add email messaging
- 🛠️ Add pushover service messaging

## [1.2.0]
- 🖌 Add option to hide reservation state of wishes for list owner
- 🖌 Add netID sign-on

## [1.1.0]
- 🖌 Add favorites of wishlists which can be managed by the user
- 🖌 Add nick name to user data which can be chosen by the user

## [1.0.0]
- 🖌
