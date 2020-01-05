@testable import Domain

struct TestingLoggingProvider: MessageLoggingProvider {

    class Messages {
        var debug = [String]()
        var info = [String]()
        var warning = [String]()
        var error = [String]()
    }

    let messages = Messages()

    func log(debug string: String, file: String, function: String, line: UInt, column: UInt) {
        messages.debug.append(string)
    }

    func log(info string: String, file: String, function: String, line: UInt, column: UInt) {
        messages.info.append(string)
    }

    func log(warning string: String, file: String, function: String, line: UInt, column: UInt) {
        messages.warning.append(string)
    }

    func log(error string: String, file: String, function: String, line: UInt, column: UInt) {
        messages.error.append(string)
    }

}
