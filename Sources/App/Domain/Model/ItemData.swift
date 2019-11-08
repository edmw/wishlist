import Vapor

/// Representation of an item without any internal properties
/// and with simple types.
/// Used for validation, importing and exporting.
struct ItemData: Content, Validatable, Reflectable {

    let title: String
    let text: String
    let preference: Item.Preference
    let url: String?
    let imageURL: String?
    let createdAt: Date?
    let modifiedAt: Date?

    init(_ item: Item) {
        self.title = item.title
        self.text = item.text
        self.preference = item.preference
        self.url = item.url?.absoluteString
        self.imageURL = item.imageURL?.absoluteString
        self.createdAt = item.createdAt
        self.modifiedAt = item.modifiedAt
    }

    init(
        title: String,
        text: String,
        preference: Item.Preference,
        url: String?,
        imageURL: String?,
        createdAt: Date?,
        modifiedAt: Date?
    ) {
        self.title = title
        self.text = text
        self.preference = preference
        self.url = url
        self.imageURL = imageURL
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }

    func with(title: String? = nil, text: String? = nil) -> ItemData {
        return ItemData(
            title: title ?? self.title,
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
        try validations.add(\.title,
            .count(Item.minimumLengthOfTitle...Item.maximumLengthOfTitle) &&
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
        using repository: ItemRepository,
        on worker: Worker
    ) throws -> EventLoopFuture<ItemData> {
        do {
            try validate()
        }
        catch let error as ValidationError {
            var properties = [PartialKeyPath<Item>]()
            // WORKAROUND: See https://github.com/vapor/validation/issues/26
            // This is a hack which parses the textual reason for an validation error.
            let reason = error.reason
            if reason.contains("'title'") {
                properties.append(\Item.title)
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
            throw EntityError<Item>.validationFailed(on: properties, reason: reason)
        }
        if let item = item {
            // validate against given item:
            // item id must exist
            guard let itemID = item.id else {
                throw EntityError<Item>.requiredIDMissing
            }
            return repository
                .find(by: itemID)
                .unwrap(or: EntityError<Item>.lookupFailed(for: itemID))
                .transform(to: self)
        }
        else {
            // validate for new item:
            // no constraints
            return worker.future(self)
        }
    }

}

// MARK: -

extension Item {

    convenience init(for list: List, from data: ItemData) throws {
        try self.init(title: data.title, text: data.text, list: list)
        self.url = URL(string: data.url)
        self.imageURL = URL(string: data.imageURL)
    }

    func update(for list: List, from data: ItemData) throws {
        guard listID == list.id else {
            throw EntityError<List>.requiredIDMismatch
        }
        title = data.title
        text = data.text
        preference = data.preference
        url = URL(string: data.url)
        imageURL = URL(string: data.imageURL)
    }

}
