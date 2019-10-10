import Foundation

final class DispatchingQueue {

    private let queue = DispatchQueue(label: "DispatchingQueue")

    private var jobs: Heap<AnyJob>

    public init(sort: @escaping (AnyJob, AnyJob) -> Bool) {
        jobs = Heap(sort: sort)
    }

    var count: Int {
        return jobs.count
    }

    var isEmpty: Bool {
        return jobs.isEmpty
    }

    var isNotEmpty: Bool {
        return jobs.isNotEmpty
    }

    public func peek() -> AnyJob? {
        return jobs.peek()
    }

    func enqueue(_ job: AnyJob) {
        queue.sync {
            jobs.insert(job)
        }
    }

    @discardableResult
    func dequeue() -> AnyJob? {
        return queue.sync {
            isNotEmpty ? jobs.remove() : nil
        }
    }

    @discardableResult
    func dequeue(_ job: AnyJob) -> AnyJob? {
        return queue.sync {
            isNotEmpty ? jobs.remove(node: job) : nil
        }
    }

    func iterate(_ block: @escaping (AnyJob) throws -> Void) throws {
       try jobs.iterate(block)
    }

}
