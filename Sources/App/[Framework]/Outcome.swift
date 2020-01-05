import Vapor

import Foundation

/// A result type which can be handled by chained future methods which return a response.
///
/// Example:
/// ```
/// final class ExampleOutcome: Outcome<Int, String> {}
///
/// let future: EventLoopFuture<ExampleOutcome> = ...
///
/// // construct a success outcome
/// future = .success(with: anIntegerValue, context: "this is the context")
///
/// // or construct a failure outcome
/// future = .failure(with: anError, context: "this is the context")
///
/// return future
///     .caseSuccess { anInt, aString -> EventLoopFuture<Response> in
///         ...
///     }
///     .caseFailure { anError, aString -> EventLoopFuture<Response> in
///         ...
///     }
/// ```
class Outcome<Value, Context: Encodable>: OutcomeType {

    /// This is the actual result of the outcome.
    let result: Result<Value, Error>

    /// This is the context for the outcome. Usually used from the outcome handlers to render a
    /// response. Can be different for different values or in the case of a failure.
    let context: Context

    /// Internal variable to store a response.
    var response: EventLoopFuture<Response>?

    /// Construct an outcome. Internal use only. Use the factory methods instead.
    /// - Parameter context: context for the outcome
    /// - Parameter result: result of the outcome
    required init(context: Context, result: Result<Value, Error>) {
        self.context = context
        self.result = result
        self.response = nil
    }

    /// Construct a successful outcome with the given value and context.
    static func success(with value: Value, context: Context) -> Self {
        return .init(context: context, result: .success(value))
    }

    /// Construct a failed outcome with the given context.
    static func failure(with error: Error, context: Context) -> Self {
        return .init(context: context, result: .failure(error))
    }

}

/// Protocol type for an outcome. Internally used to extend `EventLoopFuture`.
protocol OutcomeType {
    associatedtype Context: Encodable
    associatedtype Value

    var context: Context { get }

    var result: Result<Value, Error> { get }

    var response: EventLoopFuture<Response>? { get set }
}

// MARK: - Future

extension EventLoopFuture where Expectation: OutcomeType {

    func caseSuccess(
        _ callback: @escaping (Expectation.Value, Expectation.Context)
                                    throws -> EventLoopFuture<Response>
    ) -> EventLoopFuture<Expectation> {
        return self.map { outcome in
            guard outcome.response == nil else {
                fatalError(
                    "caseSuccess can not be called with a response set"
                        + " (call caseSuccess before caseFailure)"
                )
            }
            switch outcome.result {
            case let .success(value):
                var new = outcome
                new.response = try callback(value, outcome.context)
                return new
            case .failure:
                return outcome
            }
        }
    }

    /// Note: Do not care about the context.
    func caseSuccess(
        _ callback: @escaping (Expectation.Value)
                                    throws -> EventLoopFuture<Response>
    ) -> EventLoopFuture<Expectation> {
        return self.caseSuccess { value, _ in try callback(value) }
    }

    /// Note: Do not care about anything.
    func caseSuccess(
        _ callback: @escaping () throws -> EventLoopFuture<Response>
    ) -> EventLoopFuture<Expectation> {
        return self.caseSuccess { _, _ in try callback() }
    }

    func caseFailure (
        _ callback: @escaping (Error, Expectation.Context) throws -> EventLoopFuture<Response>
    ) -> EventLoopFuture<Response> {

        return self.flatMap { outcome in
            if let response = outcome.response {
                return response
            }
            else {
                // response = nil
                switch outcome.result {
                case .success:
                    fatalError(
                        "caseFailure can not be called with a result and with no response set"
                            + " (call caseSuccess first)"
                    )
                case let .failure(error):
                    return try callback(error, outcome.context)
                }
            }
        }
    }

    /// Note: Do not care about the error.
    func caseFailure (
        _ callback: @escaping (Expectation.Context) throws -> EventLoopFuture<Response>
    ) -> EventLoopFuture<Response> {
        return self.caseFailure { _, context in try callback(context) }
    }

    /// Note: Do not care about anything.
    func caseFailure (
        _ callback: @escaping () throws -> EventLoopFuture<Response>
    ) -> EventLoopFuture<Response> {
        return self.caseFailure { _, _ in try callback() }
    }

}
