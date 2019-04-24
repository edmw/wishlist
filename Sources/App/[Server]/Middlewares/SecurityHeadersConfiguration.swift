import Vapor

protocol SecurityHeadersConfiguration {

    func setHeader(on response: Response, from request: Request)

}

struct ContentSecurityPolicyConfiguration: SecurityHeadersConfiguration {

    private let value: String

    init(value: String) {
        self.value = value
    }

    func setHeader(on response: Response, from request: Request) {
        response.http.headers.replaceOrAdd(name: .contentSecurityPolicy, value: value)
    }

}

struct ReferrerPolicyConfiguration: SecurityHeadersConfiguration {

    enum Option: String {
        case empty = ""
        case noReferrer = "no-referrer"
        case noReferrerWhenDowngrade = "no-referrer-when-downgrade"
        case sameOrigin = "same-origin"
        case origin = "origin"
        case strictOrigin = "strict-origin"
        case originWhenCrossOrigin = "origin-when-cross-origin"
        case strictOriginWhenCrossOrigin = "strict-origin-when-cross-origin"
        case unsafeURL = "unsafe-url"
    }

    private let option: Option

    init(_ option: Option) {
        self.option = option
    }

    func setHeader(on response: Response, from request: Request) {
        response.http.headers.replaceOrAdd(name: .referrerPolicy, value: option.rawValue)
    }

}

extension HTTPHeaderName {

    static let contentSecurityPolicy
        = HTTPHeaderName("Content-Security-Policy")
    static let contentSecurityPolicyReportOnly
        = HTTPHeaderName("Content-Security-Policy-Report-Only")
    static let referrerPolicy
        = HTTPHeaderName("Referrer-Policy")

}
