import Vapor

// MARK: Job Result Type

protocol JobResult {
}

// MARK: - Some Job Result

/// Wrapper type which will be used by the type-erased job, aka `AnyJob`.
struct SomeJobResult: JobResult {

    let value: JobResult

    init(_ result: JobResult) {
        self.value = result
    }

}
