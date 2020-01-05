import Foundation

extension ValueValidator where T == String {

    static var url: ValueValidator<T> {
        return URLValidator().validator()
    }

}

private struct URLValidator: ValueValidatorType {
    typealias ValueValidationData = String

    public init() {}

    func validate(_ data: String) throws {
        guard let url = URL(string: data),
            url.isFileURL || (url.host != nil && url.scheme != nil) else {
            throw ValueValidationError("is not a valid URL")
        }
    }

    var validatorReadable: String {
        return "a valid URL"
    }

}
