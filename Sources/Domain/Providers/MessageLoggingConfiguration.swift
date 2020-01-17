import Foundation

// MARK: MessageLoggingConfiguration

public struct MessageLoggingConfiguration: LosslessStringConvertible {

    let production: Bool

    public init(production: Bool) {
        self.production = production
    }

    // MARK: LosslessStringConvertible

    public init?(_ description: String) {
        switch description {
        case "production":
            self.init(production: true)
        case "development":
            self.init(production: false)
        default:
            return nil
        }
    }

    public var description: String {
        return production ? "production" : "development"
    }

}
