import Foundation

struct ValueValidationError: ValueValidationErrorType {

    var reason: String

    var keys: [String] = []

    init(_ reason: String) {
        self.reason = reason
    }

}
