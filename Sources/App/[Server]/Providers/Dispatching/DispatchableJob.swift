import Vapor
import Leaf

// MARK: DispatchableJob

class DispatchableJob<R: JobResult>: Job, Equatable, CustomStringConvertible {
    typealias ResultType = R

    var scheduled: Date

    var deadline: Date

    var completed: EventLoopFuture<R> {
        return completedPromise.futureResult
    }
    private var completedPromise: EventLoopPromise<R>

    var cancelled: Bool = false

    init(on container: Container, at date: Date = Date(), before deadline: Date = .distantFuture) {
        self.scheduled = date
        self.deadline = deadline
        self.completedPromise = container.eventLoop.newPromise(R.self)
    }

    func run(_ context: JobContext) -> EventLoopFuture<R> {
        guard !cancelled else {
            return context.eventLoop.future(error: DispatchingError.cancelled)
        }
        return context.eventLoop.future(error: DispatchingError.noWork)
    }

    func overdue(_ context: JobContext) -> EventLoopFuture<Void> {
        self.cancelled = true
        completedPromise.fail(error: DispatchingError.overdue)
        return context.eventLoop.future(())
    }

    func success(_ context: JobContext, _ result: R) -> EventLoopFuture<Void> {
        completedPromise.succeed(result: result)
        return context.eventLoop.future(())
    }

    func failure(_ context: JobContext, _ error: Error) -> EventLoopFuture<Void> {
        completedPromise.fail(error: error)
        return context.eventLoop.future(())
    }

    // MARK: Equatable

    static func == (lhs: DispatchableJob<R>, rhs: DispatchableJob<R>) -> Bool {
        return lhs === rhs
    }

    // MARK: CustomStringConvertible

    var description: String {
        return "DispatchableJob(at: \(scheduled), before: \(deadline))"
    }

}
