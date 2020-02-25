///////////////////////////////////////////////////////////////////////////////////////////////////
// Wishlist - Site
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

struct Site: Codable, CustomDebugStringConvertible, ServiceType {

    let url: URL
    let urlComponents: URLComponents

    let release: SiteRelease

    let access: SiteAccess

    static func detect() throws -> Site {
        return try .init(
            url: Environment.require(.siteURL),
            release: Environment.require(.siteRelease),
            access: Environment.require(.siteAccess)
        )
    }

    private init(url: URL, release: SiteRelease, access: SiteAccess) {
        self.url = url
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            // fail early
            fatalError("Invalid site URL '\(url)'")
        }
        self.urlComponents = urlComponents
        self.release = release
        self.access = access
    }

    func url(withPath path: String, andQueryItems items: [String: String] = [:]) -> URL? {
        var urlComponents = self.urlComponents
        urlComponents.path = path
        urlComponents.appendQueryItems(items)
        return urlComponents.url
    }

    // MARK: - CustomDebugStringConvertible

    var debugDescription: String {
        var properties = [String]()
        properties.append("• URL = \(url)")
        properties.append("• Release = \(release)")
        properties.append("• Access = \(access)")
        return properties.joined(separator: "\n")
    }

    // MARK: - Vapor Service

    static let serviceSupports: [Any.Type] = [Site.self]

    static func makeService(for container: Container) throws -> Site {
        return try .detect()
    }

}

extension Container {

    func site() throws -> Site {
        return try make()
    }

}

extension EnvironmentKeys {
    static let siteURL = EnvironmentKey<URL>("SITE_URL")
    static let siteRelease = EnvironmentKey<SiteRelease>("SITE_RELEASE")
    static let siteAccess = EnvironmentKey<SiteAccess>("SITE_ACCESS")
}
