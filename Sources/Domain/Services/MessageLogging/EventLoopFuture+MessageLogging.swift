import Foundation
import NIO

extension EventLoopFuture {

    /// Logs a `LoggingMessage` using this future‘s value as logging subject to the specified
    /// `MessageLogging`. The specified `LoggingMessageRoot` is used to create the logging message
    /// from this future‘s value. This future‘s value is transformed into the `LoggingMessage`‘s
    /// subject by the specfied closure.
    /// - Parameter root: Factory to create a logging message from this future‘s value. This
    ///     future‘s value is processed through the specified closure `subject`, first and than
    ///     given to this factory to construct a logging message.
    /// - Parameter subject: Closure to transform this future‘s value into the logging messages‘
    ///     type. The result is passed to the specified factory to construct a logging message.
    /// - Parameter condition: Conditionally turn of logging by returning `false` from this closure.
    /// - Parameter logging: Logging target to log into.
    /// - Parameter file: #file
    /// - Parameter function: #function
    /// - Parameter line: #line
    /// - Parameter column: #column
    func logMessage<T>(
        _ root: LoggingMessageRoot<T>,
        for subject: @escaping ((Expectation) -> T),
        when condition: ((Expectation) -> Bool)? = nil,
        using logging: MessageLogging,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) -> EventLoopFuture<Expectation> {
        return self.map(to: Expectation.self) { expectationValue in
            let log: Bool
            if let condition = condition {
                log = condition(expectationValue)
            }
            else {
                log = true
            }
            if log {
                let message = root.transform(subject(expectationValue))
                logging.message(message, file: file, function: function, line: line, column: column)
            }
            return expectationValue
        }
    }

    /// Logs a `LoggingMessage` using this future‘s value as logging subject to the specified
    /// `MessageLogging`. The specified `LoggingMessageRoot` is used to create the logging message
    /// from this future‘s value.
    /// - Parameter root: Factory to create a logging message from this future‘s value.
    /// - Parameter condition: Conditionally turn of logging by returning `false` from this closure.
    /// - Parameter logging: Logging target to log into.
    /// - Parameter file: #file
    /// - Parameter function: #function
    /// - Parameter line: #line
    /// - Parameter column: #column
    func logMessage(
        _ root: LoggingMessageRoot<Expectation>,
        when condition: ((Expectation) -> Bool)? = nil,
        using logging: MessageLogging,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) -> EventLoopFuture<Expectation> {
        return self.flatMap(to: Expectation.self) { expectationValue in
            return self.logMessage(
                root,
                for: { _ in expectationValue },
                when: condition,
                using: logging,
                file: file, function: function, line: line, column: column
            )
        }
    }

    /// Logs a `LoggingMessage` using this future‘s error as logging subject to the specified
    /// `MessageLogging`. The specified `LoggingMessageRoot` is used to create the logging message
    /// from this future‘s error.
    /// - Parameter root: Factory to create a logging message from this future‘s error.
    /// - Parameter logging: Logging target to log into.
    /// - Parameter file: #file
    /// - Parameter function: #function
    /// - Parameter line: #line
    /// - Parameter column: #column
    func logError(
        _ root: LoggingMessageRoot<Error>,
        using logging: MessageLogging,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) -> EventLoopFuture<Expectation> {
        return self.thenIfErrorThrowing { error in
            let message = root.transform(error)
            logging.message(message, file: file, function: function, line: line, column: column)
            throw error
        }
    }

}
