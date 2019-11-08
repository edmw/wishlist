import Vapor

extension EventLoopFuture {

    /// emits a business event to the business logger
    func emitEvent(
        _ message: String,
        on request: Request,
        when condition: ((Expectation) -> Bool)? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) throws -> EventLoopFuture<Expectation> {
        return try self.log(
            logger: request.makeLogger().business,
            level: .custom("event"),
            message: message,
            when: condition,
            file: file,
            function: function,
            line: line,
            column: column
        )
    }

}
