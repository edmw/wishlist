import Vapor

import Foundation

/// Service to evaluate a request’s Accept-Language header if present.
///
/// This service is meant to live for the scope of a request:
/// ```
/// let RequestLanguageService = try request.privateContainer.make(RequestLanguageService.self)
/// ```
/// Then, any subsequent calls to `parse` will use the cached result of the first call.
final class RequestLanguageService: ServiceType {

    static var serviceSupports: [Any.Type] {
        return [RequestLanguageService.self]
    }

    static func makeService(for container: Container) throws
        -> RequestLanguageService
    {
        return .init()
    }

    private static var regex: NSRegularExpression {
        guard let regex = try? NSRegularExpression(
            pattern: "((([a-zA-Z]+(-[a-zA-Z0-9]+){0,2})|\\*)(;q=[0-1](\\.[0-9]+)?)?)*"
        ) else {
            fatalError("RequestLanguageService: Compiling regex pattern failed!")
        }
        return regex
    }

    var cache: (String, [RequestLanguage])?

    func parse(on request: Request) throws -> [RequestLanguage] {
        guard let header = request.http.headers[.acceptLanguage].first else {
            return []
        }

        if let (cachedHeader, cachedLanguages) = cache, cachedHeader == header {
            return cachedLanguages
        }

        let languages = RequestLanguageService.regex
            .matches(in: header, options: [], range: NSRange(header.startIndex..., in: header))
            .compactMap { match -> String? in
                guard match.range.length > 0, let range = Range(match.range, in: header)
                    else { return nil }
                return String(header[range])
            }
            .compactMap { string -> RequestLanguage? in
                let identifier = string.components(separatedBy: ";")
                guard identifier.count <= 2 else {
                    return nil
                }
                let tag = identifier[0].components(separatedBy: "-")
                guard tag.count <= 3 else {
                    return nil
                }
                let language = tag[0]
                let region = tag.count == 3 ? tag[2] : (tag.count == 2 ? tag[1] : nil)
                let script = tag.count == 3 ? tag[1] : nil
                let quality: Float
                if identifier.count == 2 {
                    let components = identifier[1].components(separatedBy: "=")
                    quality = components.count == 2 ? Float(components[1]) ?? 1.0 : 1.0
                }
                else {
                    quality = 1.0
                }
                return RequestLanguage(language, region, script, quality)
            }
            .sorted(by: { lhs, rhs -> Bool in
                lhs.quality > rhs.quality
            })

        self.cache = (header, languages)

        return languages
    }

}
