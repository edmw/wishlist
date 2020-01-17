import Foundation

// This extension makes a JSON encoder aware of its purpose for encoding log messages. This can be
// used to have different encoding strategies, for example to garble privacy or security sensitive
// data in log messages.

extension JSONEncoder {

    /// Initialise a JSON encoder marking it as encoder used for logging purposes.
    /// - Parameter configuration: Logging configuration to be attached to this encoder.
    convenience init(logging configuration: MessageLoggingConfiguration) {
        self.init()
        self.userInfo[.logging] = String(configuration)
    }

}

extension Encoder {

    /// Returns true, if this `Encoder` is used for logging purposes.
    ///
    /// Example usage for a sensitive string:
    /// ```
    /// if encoder.isLogging {
    ///     // encode:
    ///     // originalString.replacingCharacters(everyNth: 3, with: "-")
    /// }
    /// else {
    ///     // encode:
    ///     // originalString
    /// }
    /// ```
    var isLogging: Bool {
        guard let logging = userInfo[.logging] as? String else {
            return false
        }
        guard MessageLoggingConfiguration(logging) != nil else {
            return false
        }
        return true
    }

}

extension CodingUserInfoKey {

    /// Key for an encoder‘s user info to store a logging configuration.
    static var logging: CodingUserInfoKey = {
        guard let key = CodingUserInfoKey(rawValue: "Logging") else {
            fatalError("CodingUserInfoKey.init should never fail!")
        }
        return key
    }()

}
