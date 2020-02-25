import Vapor

import Foundation

/// Extends the `LogLevel` type to add a symbol to each log level (I'm a visual guy). Symbols are
/// Unicode Emojis and different sets can be used.
extension LogLevel {

    enum SymbolSet: String, CustomStringConvertible {
        case hearts
        case books
        case hands
        case weather

        var description: String { rawValue }
    }

    private func symbolForHearts() -> String {
        switch self {
        case .verbose:      return "💜"
        case .debug:        return "💙"
        case .info:         return "💚"
        case .warning:      return "🧡"
        case .error:        return "♥️"
        case .fatal:        return "🖤"
        case .custom:       return "💛"
        }
    }

    private func symbolForBooks() -> String {
        switch self {
        case .verbose:      return "📖"
        case .debug:        return "📘"
        case .info:         return "📗"
        case .warning:      return "📙"
        case .error:        return "📕"
        case .fatal:        return "📓"
        case .custom:       return "📚"
        }
    }

    private func symbolForHands() -> String {
        switch self {
        case .verbose:      return "👋"
        case .debug:        return "✋"
        case .info:         return "👍"
        case .warning:      return "☝"
        case .error:        return "👎"
        case .fatal:        return "✊"
        case .custom:       return "👌"
        }
    }

    private func symbolForWeather() -> String {
        switch self {
        case .verbose:      return "🌫"
        case .debug:        return "☁"
        case .info:         return "☀"
        case .warning:      return "🌧"
        case .error:        return "⛈"
        case .fatal:        return "🌪"
        case .custom:       return "🌀"
        }
    }

    func symbol(for set: SymbolSet = .hearts) -> String {
        switch set {
        case .hearts:   return symbolForHearts()
        case .books:    return symbolForBooks()
        case .hands:    return symbolForHands()
        case .weather:  return symbolForWeather()
        }
    }

}
