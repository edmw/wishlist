import Domain

import Vapor

// MARK: VaporEventRecordingProvider

/// Adapter for the domain layers `RecordingProvider` to be used with Vapor.
///
/// This delegates the work to the web app‘s event recording framework.
struct VaporEventRecordingProvider: EventRecordingProvider, ServiceType {

    let logger: Logger

    init(with logger: Logger) {
        self.logger = logger
    }

    func record(_ string: String, file: String, function: String, line: UInt, column: UInt) {
        self.logger.log(
            string,
            at: .custom("event"),
            file: file,
            function: function,
            line: line,
            column: column
        )
    }

    // MARK: Service

    static let serviceSupports: [Any.Type] = [EventRecordingProvider.self]

    static func makeService(for container: Container) throws -> Self {
        return .init(with: container.requireLogger().business)
    }

}
