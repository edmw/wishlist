import Vapor

// MARK: Job Context Type

/// Data which will be passed to any job methods.
struct JobContext {

    /// The eventloop on which the job will be run.
    let eventLoop: EventLoop

    /// The container in which the job will be run.
    let container: Container

    /// An initialized logger.
    let logger: Logger

}
