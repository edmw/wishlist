import Foundation

/// Collection of String parameters for use in RenderContext
struct RenderParameter: Collection, Codable {

    typealias DictionaryType = [String: String]

    var parameter = DictionaryType()

    init() {
        self.parameter = [:]
    }

    init(parameter: DictionaryType) {
        self.parameter = parameter
    }

    // merges the given dictionary into this while overwriting existing values.
    static func += (lhs: inout RenderParameter, rhs: [String: String]) {
        lhs.parameter.merge(rhs) { _, new in new }
    }

    // merges the given dictionary into this while overwriting existing values.
    // nil values are transformed into empty strings.
    static func += (lhs: inout RenderParameter, rhs: [String: String?]) {
        lhs.parameter.merge(rhs.mapValues { value in value ?? "" }) { _, new in new }
    }

    // MARK: Collection

    typealias Index = DictionaryType.Index
    typealias Element = DictionaryType.Element

    var startIndex: Index { return parameter.startIndex }
    var endIndex: Index { return parameter.endIndex }

    subscript(index: Index) -> Iterator.Element {
        return parameter[index]
    }

    func index(after index: RenderParameter.DictionaryType.Index)
        -> RenderParameter.DictionaryType.Index
    {
        return parameter.index(after: index)
    }

}
