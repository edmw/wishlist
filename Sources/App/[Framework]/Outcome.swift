import Vapor

import Foundation

/// A result type which can be handled by chained future methods which return a response.
///
/// Example:
/// ```
/// final class TheOutcome: Outcome<Int, String> {}
///
/// let future: EventLoopFuture<TheOutcome> = ...
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

    /// This is the actual result of the outcome. Contains a value on success and an optional value
    /// plus an error on failure.
    let result: Result<Value, OutcomeError<Value>>

    /// This is the context for the outcome. Usually used from the outcome handlers to render a
    /// response. Can be different for different values or in the case of a failure.
    let context: Context

    /// Internal variable to store a response.
    var response: EventLoopFuture<Response>?

    /// Construct an outcome. Internal use only. Use the factory methods instead.
    /// - Parameter context: context for the outcome
    /// - Parameter result: result of the outcome
    required init(context: Context, result: Result<Value, OutcomeError<Value>>) {
        self.context = context
        self.result = result
        self.response = nil
    }

    /// Construct a successful outcome with the given value and context.
    static func success(with value: Value, context: Context) -> Self {
        return .init(context: context, result: .success(value))
    }

    /// Construct a failed outcome with the given value, error and context.
    static func failure(with value: Value, context: Context, has error: Error) -> Self {
        return .init(context: context, result: .failure(.init(value, error)))
    }

}

struct OutcomeError<Value>: Error {

    let value: Value
    let error: Error

    init(_ value: Value, _ error: Error) {
        self.value = value
        self.error = error
    }

}

/// Protocol type for an outcome. Internally used to extend `EventLoopFuture`.
protocol OutcomeType {

    associatedtype Context: Encodable
    associatedtype Value

    var context: Context { get }

    var result: Result<Value, OutcomeError<Value>> { get }

    var response: EventLoopFuture<Response>? { get set }

}

// MARK: - Future

extension EventLoopFuture where Expectation: OutcomeType {

    func caseSuccess(
        _ callback: @escaping (Expectation.Value, Expectation.Context) throws
                                    -> EventLoopFuture<Response>
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
        _ callback: @escaping (Expectation.Value) throws
                                    -> EventLoopFuture<Response>
    ) -> EventLoopFuture<Expectation> {
        return self.caseSuccess { value, _ in try callback(value) }
    }

    /// Note: Do not care about anything.
    func caseSuccess(
        _ callback: @escaping () throws -> EventLoopFuture<Response>
    ) -> EventLoopFuture<Expectation> {
        return self.caseSuccess { _, _ in try callback() }
    }

    func caseFailure(
        _ callback: @escaping (Expectation.Value, Expectation.Context, Error) throws
                                    -> EventLoopFuture<Response>
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
                    return try callback(error.value, outcome.context, error.error)
                }
            }
        }
    }

    /// Note: Do not care about the error.
    func caseFailure (
        _ callback: @escaping (Expectation.Value, Expectation.Context) throws
                                    -> EventLoopFuture<Response>
    ) -> EventLoopFuture<Response> {
        return self.caseFailure { result, context, _ in try callback(result, context) }
    }

}
