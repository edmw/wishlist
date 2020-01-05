import Foundation

extension String {

    private static let allowedCharacters
        = NSCharacterSet(
            charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"
        )

    public func slugify() -> String? {
        var transformed: String? = self
        #if os(Linux)
        if let data = transformed?.data(using: .ascii, allowLossyConversion: true) {
            transformed = String(data: data, encoding: .ascii)
        }
        #else
        transformed = transformed?.applyingTransform(.toLatin, reverse: false)
        transformed = transformed?.applyingTransform(.stripCombiningMarks, reverse: false)
        #endif
        transformed = transformed?.lowercased()

        guard let string = transformed else {
            return nil
        }

        return string.components(separatedBy: String.allowedCharacters.inverted)
            .filter { component in
                !component.isEmpty
            }
            .joined(separator: "-")
    }

}
