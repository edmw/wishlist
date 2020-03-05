import Vapor

import Foundation

// MARK: DispatchingService

/// Service to schedule tasks.
final class DispatchingService: Service, CustomStringConvertible {

    /// Jobs queue sorted ascending by scheduling date
    private var queue = DispatchingQueue(sort: { lhs, rhs in
        return lhs.scheduled(before: rhs)
    })

    /// Jobs queue sorted ascending by deadline
    private var queueDeadline = DispatchingQueue(sort: { lhs, rhs in
        return lhs.deadline(before: rhs)
    })

    private var container: Container?

    private var eventLoop: EventLoop?
    private var eventLoopTask: RepeatedTask?

    private var dnaTask: RepeatedTask?

    private var isShuttingDown: Bool = false

    private var logger: Logger?

    func attach(to application: Application, logger: Logger) throws {
        precondition(
            self.container == nil,
            "Could not attach dispatching service when already attached."
        )
        self.container = application
        self.eventLoop = application.eventLoop
        self.isShuttingDown = false
        self.logger = logger

        self.dnaTask = try scheduleDNA()
    }

    @discardableResult
    func dispatch<J: Job & Equatable & CustomStringConvertible>(_ job: J)
        throws -> EventLoopFuture<Void>
    {
        guard let eventLoop = eventLoop else {
            throw DispatchingError.noContainer
        }

        let anyJob = AnyJob(job)
        queue.enqueue(anyJob)
        queueDeadline.enqueue(anyJob)

        return eventLoop.future(())
    }

    func start() throws {
        guard let container = container, let eventLoop = eventLoop, let logger = logger else {
            throw DispatchingError.noContainer
        }

        // start the repeated service task which will execute the scheduled jobs
        eventLoopTask = eventLoop.scheduleRepeatedTask(
            initialDelay: .seconds(0),
            delay: .milliseconds(1_000)
        ) { task in
            // run the repeated service task which will execute the scheduled jobs
            return self.run(on: eventLoop, in: container, logger: logger)
                .map {
                    // cancel this service task if flag is set
                    if self.isShuttingDown {
                        task.cancel()
                    }
                }
                .catch { error in
                    // jobs are executed in the background with no user interface,
                    // so catch and log all possible errors
                    logger.error("\(self): Failed with \(error)")
                }
        }
    }

    func stop() {
        // set flag for the service task to shutdown down
        isShuttingDown = true
    }

    private func run(
        on eventLoop: EventLoop,
        in container: Container,
        logger: Logger
    ) -> EventLoopFuture<Void> {
        let date = Date()

        // remove all cancelled jobs from the head of the queue
        while let first = queue.peek(), first.cancelled {
            queue.dequeue(first)
            queueDeadline.dequeue(first)
        }

        // get the earliest job from the queue and check if it's time to execute
        guard let first = queue.peek(), first.scheduled <= date else {
            return eventLoop.future(())
        }

        // remove the earliest job from the queue
        // in fact, a race condition can happen here, if the first job in the queue gets
        // removed between the date check above and this call. while removal of a job
        // should not be a common usage pattern, this will be ignored for now. a more defensive
        // strategy would be to remove the first job, check the date again and requeue it
        // if it's not the time to run it.
        guard let job = queue.dequeue() else {
            return eventLoop.future(())
        }
        // remove job from deadline queue, too
        queueDeadline.dequeue(job)

        let context = JobContext(eventLoop: eventLoop, container: container, logger: logger)

        // check if the deadline of the job is elapsed
        if job.deadline < date {
            logger.info("\(self): Job \(job) overdue")
            return job.overdue(context)
        }

        // execute job
        return execute(job, in: context)
    }

    /// Executes the specified job in the specified job context.
    ///
    /// - Parameter job: job to be executed
    /// - Parameter context: context for the execution of the job
    ///
    /// Do **not** call this method on jobs which are enqueued in a job queue. This will result
    /// in an illegal state of the job queue.
    func execute<J: Job & Equatable & CustomStringConvertible>(_ job: J, in context: JobContext)
        -> EventLoopFuture<Void>
    {
        context.logger.info("\(self): Execute \(job)")
        return job.run(context)
            .flatMap { result in
                context.logger.info("\(self): \(job) succeeded with result: \(result)")
                return job.success(context, result)
            }
            .catchFlatMap { error in
                context.logger.error("\(self): \(job) failed with error: \(error)")
                return job.failure(context, error)
            }
    }

    // MARK: DNA

    // "I love deadlines. I like the whooshing sound they make as they fly by."
    func scheduleDNA() throws -> RepeatedTask {
        guard let container = container, let eventLoop = eventLoop, let logger = logger else {
            throw DispatchingError.noContainer
        }

        // start the repeated service task which will check the jobs deadlines
        return eventLoop.scheduleRepeatedTask(
            initialDelay: .seconds(0),
            delay: .milliseconds(1_000)
        ) { _ in
            // run the repeated service task which will check the jobs deadlines
            return self.runDNA(on: eventLoop, in: container, logger: logger)
        }
    }

    private func runDNA(
        on eventLoop: EventLoop,
        in container: Container,
        logger: Logger
    ) -> EventLoopFuture<Void> {
        let date = Date()

        var futures = [EventLoopFuture<Void>]()

        // get the a job from the deadline queue and check if it's deadline has expired
        while let first = self.queueDeadline.peek(), first.deadline <= date {
            guard let job = self.queueDeadline.dequeue() else {
                continue
            }

            let context = JobContext(eventLoop: eventLoop, container: container, logger: logger)

            // overdue job
            logger.error("\(self): Job \(job) overdue")
            futures.append(
                job.cancel(context).flatMap { _ in
                    return job.overdue(context).map { _ in
                        self.queue.dequeue(job)
                    }
                }
            )
        }

        return futures.flatten(on: container)
    }

    // MARK: CustomStringConvertible

    var description: String {
        return "DispatchingService"
    }

}
