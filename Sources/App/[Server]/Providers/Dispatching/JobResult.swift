// MARK: Job Result Type

protocol JobResult {
}

extension Bool: JobResult {}

// MARK: - Some Job Result

/// Wrapper type which will be used by the type-erased job, aka `AnyJob`.
struct SomeJobResult: JobResult, CustomStringConvertible {

    let value: JobResult

    init(_ result: JobResult) {
        self.value = result
    }

    // MARK: CustomStringConvertible

    var description: String {
        return "SomeJobResult(\(value))"
    }

}
