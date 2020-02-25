///////////////////////////////////////////////////////////////////////////////////////////////////
// Wishlist - boot
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

import Domain

import Vapor

public func boot(_ app: Application) throws {
    let logger = try app.makeLogger()
    logger.application.info("LOGGING:\n\(String(reflecting: logger))\n")

    let environment = app.environment
    logger.application.info("ENVIRONMENT:\n\(String(reflecting: environment))\n")
    let site = try app.site()
    logger.application.info("SITE:\n\(String(reflecting: site))\n")
    let features = try app.makeFeatures()
    logger.application.info("FEATURES:\n\(String(reflecting: features))\n")

    let dispatchingService = try app.make(DispatchingService.self)
    try dispatchingService.attach(to: app, logger: logger)
    try dispatchingService.start()
    try dispatchingService.dispatch(VaporImageStoreProvider.CleanupJob(on: app))
}

extension Environment: CustomDebugStringConvertible {

    public var debugDescription: String {
        var properties = [String]()
        properties.append("• Name = \(name)")
        properties.append("• Release = \(isRelease)")
        properties.append("• Arguments = \(arguments)")
        return properties.joined(separator: "\n")
    }

}
