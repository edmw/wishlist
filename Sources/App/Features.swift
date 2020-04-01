///////////////////////////////////////////////////////////////////////////////////////////////////
// Wishlist - Features
//
// Copyright (c) 2019-2020 Michael Baumgärtner
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
///////////////////////////////////////////////////////////////////////////////////////////////////

import Vapor
import Foundation

struct Features: Encodable, CustomDebugStringConvertible, ServiceType {
    // swiftlint:disable operator_usage_whitespace

    // business
    let welcomePage              = Feature(date: "2018-10-20", version: "1.0")
    let errorPages               = Feature(date: "2018-10-20", version: "1.0")
    let signupRestrictions       = Feature(date: "2018-10-30", version: "1.0")
    let signupInvitations        = Feature(date: "2018-12-08", version: "1.0")
    let limitNumberOfInvitations = Feature(date: "2018-12-10", version: "1.0")
    let invitationEmails         = Feature(date: "2020-01-05", version: "1.4")
    let signinWithGoogle         = Feature(date: "2018-10-20", version: "1.0")
    let signinWithNetID          = Feature(date: "2019-10-10", version: "1.2")
    let userWelcomePage          = Feature(date: "2018-10-20", version: "1.0")
    let userSettings             = Feature(date: "2019-10-15", version: "1.3")
    let userNotifications        = Feature(date: "2019-10-15", version: "1.3")
    // users
    let userProfilePage          = Feature(date: "2018-10-20", version: "1.0")
    let userNickname             = Feature(date: "2019-04-24", version: "1.1")
    // lists
    let createList               = Feature(date: "2018-10-24", version: "1.0")
    let limitNumberOfLists       = Feature(date: "2018-12-10", version: "1.0")
    let deleteList               = Feature(date: "2018-10-24", version: "1.0")
    let showLists                = Feature(date: "2018-10-24", version: "1.0")
    let maskReservationsOnList   = Feature(date: "2019-09-17", version: "1.2")
    let sortOrderForLists        = Feature(date: "2019-04-21", version: "1.0")
    let editList                 = Feature(date: "2018-10-26", version: "1.0")
    let favorList                = Feature(date: "2019-09-13", version: "1.1")
    let exportList               = Feature(date: "2019-03-26", version: "1.0")
    let importList               = Feature(date: "2019-03-26", version: "1.0")
    // items
    let createItem               = Feature(date: "2018-10-29", version: "1.0")
    let limitNumberOfItems       = Feature(date: "2018-12-10", version: "1.0")
    let deleteItem               = Feature(date: "2018-10-29", version: "1.0")
    let moveItem                 = Feature(date: "2020-03-08", version: "1.5")
    let receiveItem              = Feature(date: "2020-03-20", version: "1.6")
    let archiveItem              = Feature(date: "2020-04-01", version: "1.6")
    let showItems                = Feature(date: "2018-10-29", version: "1.0")
    let sortOrderForItemsOnList  = Feature(date: "2019-04-22", version: "1.0")
    let editItems                = Feature(date: "2018-10-29", version: "1.0")
    let itemImage                = Feature(date: "2018-11-03", version: "1.0")
    let itemDescription          = Feature(date: "2018-11-06", version: "1.0")
    let itemPreference           = Feature(date: "2019-04-23", version: "1.0")
    let itemPrice                = Feature.inPlanning(.low)
    let notifyCreateItem         = Feature.inPlanning(.high)
    // reservations
    let makeReservation          = Feature(date: "2018-11-19", version: "1.0")
    let undoReservation          = Feature(date: "2018-11-19", version: "1.0")
    let notifyCreateReservation  = Feature(date: "2019-10-15", version: "1.3")
    let notifyDeleteReservation  = Feature(date: "2019-10-15", version: "1.3")
    // presentation
    let showWishlist             = Feature(date: "2018-11-19", version: "1.0")
    // technical
    let localization             = Feature(date: "2018-11-28", version: "1.0")
    let preventCSRF              = Feature(date: "2018-11-20", version: "1.0")
    let dispatchableJobs         = Feature(date: "2019-10-15", version: "1.3")
    let emailMessaging           = Feature(date: "2019-10-15", version: "1.3")
    let pushoverMessaging        = Feature(date: "2019-10-15", version: "1.3")
    let rateLimitNotifications   = Feature.inPlanning(.normal)

    // MARK: CustomDebugStringConvertible

    var debugDescription: String {
        var features = [(label: String, feature: Feature)]()

        // collect
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            if let label = child.label, let value = child.value as? Feature {
                features.append((label: "• \(label)", feature: value))
            }
        }

        // sort and format
        let maximumLabelLength = features.map { element in element.label.count }.max() ?? 0
        return features
            .sorted(
                by: { $0.feature < $1.feature }
            )
            .map { element in
                let label = element.label.padding(
                    toLength: maximumLabelLength,
                    withPad: " ",
                    startingAt: 0
                )
                return "\(label) = \(element.feature)"
            }
            .joined(separator: "\n")
    }

    // MARK: Vapor Service

    static var serviceSupports: [Any.Type] {
        return [Features.self]
    }

    static func makeService(for container: Container) throws
        -> Features
    {
        return .init()
    }

}

// MARK: -

extension Container {

    var features: Features? {
        return try? make()
    }

    func makeFeatures() throws -> Features {
        return try make()
    }

}
