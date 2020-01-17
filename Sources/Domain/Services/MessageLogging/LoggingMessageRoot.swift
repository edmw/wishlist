import Foundation

// MARK: LoggingMessageRoot

/// Factory to create a logging message with an subject of type T.
struct LoggingMessageRoot<T> {

    /// Closure to create a logging message with an subject of type T.
    var transform: (T) -> LoggingMessage

    /// Initialise this factory with the given closure to create a logging message with an subject
    /// of type T.
    ///
    /// How to define a static method to return an initialized `LoggingMessageRoot` as a
    /// factory for User-Login logging messages (this can be passed to any log function which
    /// needs a logging message factory and can provide a user as subject):
    ///
    /// ```
    /// fileprivate static var materialiseUser: LoggingMessageRoot<User> {
    ///     return .init({ user in
    ///         LoggingMessage(label: "User Login", subject: user, loggables: [timestamp, remoteIP])
    ///     })
    /// }
    /// ```
    ///
    /// For usage see `EventLoopFuture+MessageLogging`.
    ///
    /// - Parameter transform: Closure to create a logging message.
    init(_ transform: @escaping (T) -> LoggingMessage) {
        self.transform = transform
    }

}
