import Vapor

import Foundation

/// This is a logger processor which adds a textual tag to each the log message.
/// Forwards any log message to the specified target logger then.
///
/// Configuration:
/// - Tag string
/// - Target logger
class TaggedLogger: Logger, Service, CustomStringConvertible {

    let target: Logger

    let tag: String

    init(target logger: Logger, tag: String) {
        self.target = logger
        self.tag = tag
    }

    func log(
        _ string: String,
        at level: LogLevel,
        file: String,
        function: String,
        line: UInt,
        column: UInt
    ) {
        let taggedString = [tag, string].joined(separator: " ")
        target.log(
            taggedString,
            at: level,
            file: file,
            function: function,
            line: line,
            column: column
        )
    }

    // MARK: CustomStringConvertible

    var description: String {
        return String(describing: type(of: self)) + "(tag=\(tag), target=\(target))"
    }

}
