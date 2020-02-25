import Vapor

import Foundation
import Dispatch

/// This is a logger logging to the console.
/// Features:
/// - adds a timestamp to the log message
/// - adds a symbol for the log level to the log message
///
/// Configuration:
/// - Set of symbols to use for the log level
class ConsoleLogger: Logger, Service, CustomStringConvertible {

    static let lock = DispatchQueue(label: "de.yamanote.wl.ConsoleLogger")

    let set: LogLevel.SymbolSet

    let start = Date()

    init(symbols: LogLevel.SymbolSet = .hearts) {
        self.set = symbols
    }

    func log(
        _ string: String,
        at level: LogLevel,
        file: String,
        function: String,
        line: UInt,
        column: UInt
    ) {
        ConsoleLogger.lock.sync {
            Swift.print([
                "\(time())",
                "\(level.symbol(for: set))",
                "[\(level)]",
                "\(string)",
                "(\(file):\(function):\(line):\(column))"
                ].joined(separator: " ")
            )
        }
    }

    /// Calculates and formats the time since creation of the Logger and calling time.
    func time() -> String {
        let interval = Date().timeIntervalSince(start)

        let hours = Int(interval) / 3_600
        let minutes = Int(interval / 60) - Int(hours * 60)
        let seconds = Int(interval) - (Int(interval / 60) * 60)
        let milliseconds = Int(interval.truncatingRemainder(dividingBy: 1) * 1_000)

        return String(
            format: "%0.2d:%0.2d:%0.2d.%03d", arguments: [hours, minutes, seconds, milliseconds]
        )
    }

    // MARK: CustomStringConvertible

    var description: String {
        return String(describing: type(of: self)) + "(symbols=\(set))"
    }

}
