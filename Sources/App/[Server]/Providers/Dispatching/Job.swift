import Vapor

// MARK: Job Type

/// Protocol to be adopted by any type which should be runnable by the Dispatching Service.
/// Usually you don't want to implement all functionality by yourself, but subclass any of the
/// provided job types, for example `DispatchableJob`.
protocol Job {
    /// The result type associated with the job and returned after successful execution.
    associatedtype ResultType: JobResult

    /// Point in time when this job should be run.
    /// Note: If this lies in the past and the job has not been run yet, it will be executed.
    var scheduled: Date { get }

    /// Point in time when this job should be cancelled.
    /// Note: If this is reached, the jobs `overdue` method will be called.
    var deadline: Date { get }

    /// True, if the job is cancelled.
    /// Note: Even if this returns true, the jobs `run` method may still be called.
    var cancelled: Bool { get }

    /// This will be called to execute the job.
    /// - parameter context context in which the job will be executed
    /// - returns: a future which will be fulfilled after the execution terminates
    /// Note: While the Dispatching Service will execute the job on a background thread, the
    /// result of this method will not be returned to the initiator of a job. See
    /// `DispatchableJob` on how a job can utilize another promise to enable the initiator
    /// to wait for the result of a job.
    func run(_ context: JobContext) -> EventLoopFuture<ResultType>

    /// This will be called to cancel the job.
    /// - parameter context context in which the job will be executed
    func cancel(_ context: JobContext) -> EventLoopFuture<Void>

    /// This will be called after the job was successfully executed.
    /// - parameter context context in which the job will be executed
    /// - parameter result result of the successful execution of the job
    func success(_ context: JobContext, _ result: ResultType) -> EventLoopFuture<Void>

    /// This will be called after the job terminated with an error.
    /// - parameter context context in which the job will be executed
    /// - parameter error error which occured while executing the job
    func failure(_ context: JobContext, _ error: Error) -> EventLoopFuture<Void>

    /// This will be called if the job is overdue.
    /// - parameter context context in which the job will be executed
    func overdue(_ context: JobContext) -> EventLoopFuture<Void>

}

// MARK: -

// MARK: Type Erasure: Abstract Base

private class AnyJobBase: Job {

    var cancelled: Bool { fatalError("abstract") }

    var scheduled: Date { fatalError("abstract") }

    var deadline: Date { fatalError("abstract") }

    func run(_ context: JobContext) -> EventLoopFuture<SomeJobResult> {
        fatalError("abstract")
    }

    func cancel(_ context: JobContext) -> EventLoopFuture<Void> {
        fatalError("abstract")
    }

    func success(
        _ context: JobContext,
        _ result: SomeJobResult
    ) -> EventLoopFuture<Void> {
        fatalError("abstract")
    }

    func failure(_ context: JobContext, _ error: Error) -> EventLoopFuture<Void> {
        fatalError("abstract")
    }

    func overdue(_ context: JobContext) -> EventLoopFuture<Void> {
        fatalError("abstract")
    }

    func equal(to base: AnyJobBase) -> Bool {
        fatalError("abstract")
    }

    var description: String {
        fatalError("abstract")
    }

}

// MARK: Type Erasure: Private Box

fileprivate final class AnyJobBox<Concrete: Job>: AnyJobBase
    where Concrete: Equatable & CustomStringConvertible
{

    var concrete: Concrete

    init(_ concrete: Concrete) {
        self.concrete = concrete
    }

    override var cancelled: Bool { return concrete.cancelled }

    override var scheduled: Date { return concrete.scheduled }

    override var deadline: Date { return concrete.deadline }

    override func run(_ context: JobContext) -> EventLoopFuture<SomeJobResult> {
        return concrete.run(context).map { return SomeJobResult($0) }
    }

    override func cancel(_ context: JobContext) -> EventLoopFuture<Void> {
        return concrete.cancel(context)
    }

    override func success(
        _ context: JobContext,
        _ result: SomeJobResult
    ) -> EventLoopFuture<Void> {
        guard let result = result.value as? Concrete.ResultType else {
            return context.eventLoop.newFailedFuture(error: Abort(.internalServerError))
        }
        return concrete.success(context, result)
    }

    override func failure(_ context: JobContext, _ error: Error) -> EventLoopFuture<Void> {
        return concrete.failure(context, error)
    }

    override func overdue(_ context: JobContext) -> EventLoopFuture<Void> {
        return concrete.overdue(context)
    }

    override func equal(to base: AnyJobBase) -> Bool {
        guard let anybox = base as? AnyJobBox<Concrete> else {
            fatalError("type mismatch")
        }
        return self.concrete == anybox.concrete
    }

    override var description: String {
        return concrete.description
    }

}

// MARK: Type Erasure: Public Wrapper

final class AnyJob: Job, Equatable, CustomStringConvertible {

    private let anybox: AnyJobBase

    init<Concrete: Job>(_ concrete: Concrete)
        where Concrete: Equatable & CustomStringConvertible
    {
        anybox = AnyJobBox(concrete)
    }

    var cancelled: Bool { return anybox.cancelled }

    var scheduled: Date { return anybox.scheduled }

    func scheduled(before job: AnyJob) -> Bool {
        return self.scheduled < job.scheduled
    }

    var deadline: Date { return anybox.deadline }

    func deadline(before job: AnyJob) -> Bool {
        return self.deadline < job.deadline
    }

    func run(_ context: JobContext) -> EventLoopFuture<SomeJobResult> {
        return anybox.run(context)
    }

    func cancel(_ context: JobContext) -> EventLoopFuture<Void> {
        return anybox.cancel(context)
    }

    func success(
        _ context: JobContext,
        _ result: SomeJobResult
    ) -> EventLoopFuture<Void> {
        return anybox.success(context, result)
    }

    func failure(_ context: JobContext, _ error: Error) -> EventLoopFuture<Void> {
        return anybox.failure(context, error)
    }

    func overdue(_ context: JobContext) -> EventLoopFuture<Void> {
        return anybox.overdue(context)
    }

    static func == (lhs: AnyJob, rhs: AnyJob) -> Bool {
        return lhs.anybox.equal(to: rhs.anybox)
    }

    var description: String {
        return anybox.description
    }

}
