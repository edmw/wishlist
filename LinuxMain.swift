import XCTest
@testable import AppTests
@testable import DomainTests
@testable import LibraryTests

XCTMain([
    // LibraryTests
    testCase(UUIDTests.__allTests),
    // DomainTests
    testCase(AnnouncementsActorTests.__allTests),
    testCase(EnrollmentActorTests.__allTests),
    testCase(InvitationTests.__allTests),
    testCase(TestingUserRepositoryTests.__allTests),
    // AppTests
    testCase(DomainModelInvitationTests.__allTests),
    testCase(DomainModelItemTests.__allTests),
    testCase(DomainModelListTests.__allTests),
    testCase(DomainModelReservationTests.__allTests),
    testCase(DomainModelUserTests.__allTests),
    testCase(RequestLanguageServiceTests.__allTests)
])
