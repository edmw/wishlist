import Vapor

import Foundation

// MARK: DispatchingService

/// Service to schedule tasks.
final class DispatchingService: Service {

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

    private var isShuttingDown: Bool = false

    private var logger: Logger?

    func attach(to container: Container, logger: Logger) {
        self.container = container
        self.eventLoop = container.next()
        self.isShuttingDown = false
        self.logger = logger
    }

    func dispatch(_ job: AnyJob) throws -> EventLoopFuture<Void> {
        guard let eventLoop = eventLoop else {
            throw DispatchingError.noContainer
        }

        queue.enqueue(job)
        queueDeadline.enqueue(job)

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
                    logger.error("Dispatching: Failed with \(error)")
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
            logger.info("Dispatching: Job \(job) overdue")
            return job.overdue(context)
        }

        // execute job
        logger.info("Dispatching: Running \(job)")
        return job.run(context)
            .flatMap { result in
                return job.success(context, result)
            }
            .catchFlatMap { error in
                logger.error("Dispatching: Job \(job) failed with \(error)")
                return job.failure(context, error)
            }
    }

    // "I love deadlines. I like the whooshing sound they make as they fly by."
    func scheduleDNA() throws {
        guard let container = container, let eventLoop = eventLoop, let logger = logger else {
            throw DispatchingError.noContainer
        }

        // start the repeated service task which will check the jobs deadlines
        eventLoop.scheduleRepeatedTask(
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
            logger.error("Dispatching: Job \(job) overdue")
            futures.append(
                job.overdue(context)
                    .map { _ in
                        return self.queue.dequeue(job)
                    }
                    .transform(to: ())
            )
        }

        return futures.flatten(on: container)
    }

}
