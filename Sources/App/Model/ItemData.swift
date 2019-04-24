import Vapor

/// Representation of an item without any internal properties
/// and with simple types.
/// Used for validation, importing and exporting.
struct ItemData: Content, Validatable, Reflectable {

    let name: String
    let text: String
    let preference: Item.Preference
    let url: String?
    let imageURL: String?
    let createdAt: Date?
    let modifiedAt: Date?

    init(_ item: Item) {
        self.name = item.name
        self.text = item.text
        self.preference = item.preference
        self.url = item.url?.absoluteString
        self.imageURL = item.imageURL?.absoluteString
        self.createdAt = item.createdAt
        self.modifiedAt = item.modifiedAt
    }

    init(
        name: String,
        text: String,
        preference: Item.Preference,
        url: String?,
        imageURL: String?,
        createdAt: Date?,
        modifiedAt: Date?
    ) {
        self.name = name
        self.text = text
        self.preference = preference
        self.url = url
        self.imageURL = imageURL
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }

    func with(name: String? = nil, text: String? = nil) -> ItemData {
        return ItemData(
            name: name ?? self.name,
            text: text ?? self.text,
            preference: self.preference,
            url: self.url,
            imageURL: self.imageURL,
            createdAt: self.createdAt,
            modifiedAt: self.modifiedAt
        )
    }

    // MARK: Validatable

    static func validations() throws -> Validations<ItemData> {
        var validations = Validations(ItemData.self)
        try validations.add(\.name,
            .count(Item.minimumLengthOfName...Item.maximumLengthOfName) &&
            .characterSet(
                .alphanumerics +
                .whitespaces +
                .punctuationCharacters
            )
        )
        try validations.add(\.text,
            .count(0...Item.maximumLengthOfText)
        )
        try validations.add(\.url,
            (.nil || .empty || (.url && .count(0...Item.maximumLengthOfURL)))
        )
        try validations.add(\.imageURL,
            (.nil || .empty || (.url && .count(0...Item.maximumLengthOfURL)))
        )
        return validations
    }

    /// Validates the given item data on conformance to the constraints of the model.
    /// - Values must validate (see Validatable)
    /// - When validating against a given item, the specified item must exist in the database.
    func validate(
        for list: List,
        this item: Item? = nil,
        using repository: ItemRepository
    ) throws -> Future<ItemData> {
        do {
            try validate()
        }
        catch let error as ValidationError {
            var properties = [PartialKeyPath<Item>]()
            // WORKAROUND: See https://github.com/vapor/validation/issues/26
            // This is a hack which parses the textual reason for an validation error.
            let reason = error.reason
            if reason.contains("'name'") {
                properties.append(\Item.name)
            }
            if reason.contains("'text'") {
                properties.append(\Item.text)
            }
            if reason.contains("'url'") {
                properties.append(\Item.url)
            }
            if reason.contains("'imageURL'") {
                properties.append(\Item.imageURL)
            }
            throw EntityError.validationFailed(on: properties, reason: reason)
        }
        if let item = item {
            // validate against given item:
            // item id must exist
            guard let itemID = item.id else {
                throw ModelError<Item>.requiredIDMissing
            }
            return repository
                .find(by: itemID)
                .unwrap(or: EntityError<Item>.lookupFailed(for: itemID))
                .transform(to: self)
        }
        else {
            // validate for new item:
            // no constraints
            return repository.future(self)
        }
    }

}

// MARK: -

extension Item {

    convenience init(for list: List, from data: ItemData) throws {
        try self.init(name: data.name, text: data.text, list: list)
        self.url = URL(string: data.url)
        self.imageURL = URL(string: data.imageURL)
    }

    func update(for list: List, from data: ItemData) throws {
        guard listID == list.id else {
            throw ModelError<List>.requiredIDMismatch
        }
        name = data.name
        text = data.text
        preference = data.preference
        url = URL(string: data.url)
        imageURL = URL(string: data.imageURL)
    }

}
