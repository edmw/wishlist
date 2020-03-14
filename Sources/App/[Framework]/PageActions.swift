// MARK: PageAction

struct PageActions: Collection, Encodable {

    typealias ContentsType = [String: PageAction]

    private var contents = ContentsType()

    subscript(key: String) -> PageAction? {
        get {
            contents[key]
        }
        set {
            contents[key] = newValue
        }
    }

    // MARK: Collection

    typealias Index = ContentsType.Index
    typealias Element = ContentsType.Element

    var startIndex: Index { return contents.startIndex }
    var endIndex: Index { return contents.endIndex }

    subscript(index: Index) -> ContentsType.Iterator.Element {
        return contents[index]
    }

    func index(after index: PageActions.ContentsType.Index)
        -> PageActions.ContentsType.Index
    {
        return contents.index(after: index)
    }

    // Encodable

    /// Encodes all key value pairs from contents dictionary as
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: AnyCodingKey.self)
        for key in contents.keys {
            guard let action = contents[key],
                  let codingkey = AnyCodingKey(stringValue: key)
            else {
                continue
            }
            try container.encode(action, forKey: codingkey)
        }
    }

}

private struct AnyCodingKey: CodingKey {

    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
    }

    init?(intValue: Int) {
        self.intValue = intValue
        self.stringValue = "\(intValue)"
    }

}
