// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


// sourcery:inline:AutoLinuxMain

// MARK: DO NOT EDIT

import XCTest
@testable import AppTests
@testable import DomainTests
@testable import LibraryTests

XCTMain([
    // AppTests
    testCase(AppTests.EnvironmentDotEnvTests.__allTests),
    testCase(AppTests.EnvironmentTests.__allTests),
    testCase(AppTests.FavoriteTests.__allTests),
    testCase(AppTests.ImageFileLocatorTests.__allTests),
    testCase(AppTests.InvitationTests.__allTests),
    testCase(AppTests.ItemTests.__allTests),
    testCase(AppTests.ListTests.__allTests),
    testCase(AppTests.RequestLanguageServiceTests.__allTests),
    testCase(AppTests.ReservationTests.__allTests),
    testCase(AppTests.UserTests.__allTests),
    // DomainTests
    testCase(DomainTests.AnnouncementsActorTests.__allTests),
    testCase(DomainTests.EnrollmentActorTests.__allTests),
    testCase(DomainTests.EntityTests.__allTests),
    testCase(DomainTests.IdentifierTests.__allTests),
    testCase(DomainTests.InvitationTests.__allTests),
    testCase(DomainTests.ItemTests.__allTests),
    testCase(DomainTests.UserItemsActorTests.__allTests),
    testCase(DomainTests.ValidationTests.__allTests),
    testCase(DomainTests.WishlistActorTests.__allTests),
    // LibraryTests
    testCase(LibraryTests.BitArrayTests.__allTests),
    testCase(LibraryTests.BloomFilterTests.__allTests),
    testCase(LibraryTests.FileManagerTests.__allTests),
    testCase(LibraryTests.HeapTests.__allTests),
    testCase(LibraryTests.StringTests.__allTests),
    testCase(LibraryTests.URLTests.__allTests),
    testCase(LibraryTests.UUIDTests.__allTests),
    // Other
    testCase(TestingUserRepositoryTests.__allTests)
])

// sourcery:end
