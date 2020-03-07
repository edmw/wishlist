import Vapor

extension EventLoopFuture {

    // log a message together with a description of this future’s expectation 
    func log(
        logger: Logger,
        level: LogLevel = .error,
        message: String,
        when condition: ((Expectation) -> Bool)? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) -> EventLoopFuture<Expectation> {
        return self.map { value in
            let log: Bool
            if let condition = condition {
                log = condition(value)
            }
            else {
                log = true
            }
            if log {
                let description = String(describing: value)
                logger.log(
                    "\(description) \(message)",
                    at: level,
                    file: file,
                    function: function,
                    line: line,
                    column: column
                )
            }
            return value
        }
    }

    func log(
        _ message: String,
        to logger: Logger,
        when condition: ((Expectation) -> Bool)? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) -> EventLoopFuture<Expectation> {
        return self.log(
            logger: logger,
            level: .info,
            message: message,
            when: condition,
            file: file,
            function: function,
            line: line,
            column: column
        )
    }

    func logMessage(
        _ message: String,
        on request: Request,
        to logger: Logger? = nil,
        when condition: ((Expectation) -> Bool)? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) -> EventLoopFuture<Expectation> {
        return self.log(
            logger: logger ?? request.requireLogger().application,
            level: .info,
            message: message,
            when: condition,
            file: file,
            function: function,
            line: line,
            column: column
        )
    }

}
