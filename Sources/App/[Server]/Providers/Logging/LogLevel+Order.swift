import Vapor

import Foundation

/// Extends the `LogLevel` type to add cardinality to each log level, so that log levels can be
/// ordered and compared.
/// Note: This does not work very well with any `custom` log level, which will get the highest
/// cardinality (even higher than `fatal`) and will not be distinct for different associated values.
/// At least, if defining a filter on a minimum level, custom log messages will always be logged.
extension LogLevel {

    var order: Int {
        switch self {
        case .verbose:      return 0
        case .debug:        return 1
        case .info:         return 2
        case .warning:      return 3
        case .error:        return 4
        case .fatal:        return 5
        case .custom:       return 6
        }
    }

}

// MARK: Equatable

extension LogLevel: Equatable {

    public static func == (lhs: LogLevel, rhs: LogLevel) -> Bool {
        return lhs.order == rhs.order
    }

}

// MARK: Comparable

extension LogLevel: Comparable {

    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        return lhs.order < rhs.order
    }

}
