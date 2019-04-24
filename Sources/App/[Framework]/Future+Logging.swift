import Vapor

extension Future {

    func log(
        logger: Logger,
        level: LogLevel = .error,
        message: String,
        when condition: ((Expectation) -> Bool)? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) -> Future<Expectation> {
        return self.map(to: Expectation.self) { value in
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

    func info(
        _ message: String,
        to logger: Logger,
        when condition: ((Expectation) -> Bool)? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) -> Future<Expectation> {
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

}