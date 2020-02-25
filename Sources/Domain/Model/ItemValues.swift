import Foundation
import NIO

// MARK: ItemValues

/// Representation of an item without any internal properties and with simple types.
/// Used for validation, importing and exporting.
public struct ItemValues: Values, ValueValidatable {

    public var title: String
    public var text: String
    public var preference: Item.Preference
    public var url: String?
    public var imageURL: String?
    public var createdAt: Date?
    public var modifiedAt: Date?

    init(_ item: Item) {
        self.title = String(item.title)
        self.text = String(item.text)
        self.preference = item.preference
        self.url = item.url?.absoluteString
        self.imageURL = item.imageURL?.absoluteString
        self.createdAt = item.createdAt
        self.modifiedAt = item.modifiedAt
    }

    init(_ values: PartialValues<ItemValues>) throws {
        self.title = try values.value(for: \.title)
        self.text = try values.value(for: \.text)
        self.preference = try values.value(for: \.preference)
        self.url = try values.value(for: \.url)
        self.imageURL = try values.value(for: \.imageURL)
        self.createdAt = values[\.createdAt]
        self.modifiedAt = values[\.modifiedAt]
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

    public init(
        title: String,
        text: String,
        preference: String,
        url: String?,
        imageURL: String?,
        createdAt: Date?,
        modifiedAt: Date?
    ) {
        self.title = title
        self.text = text
        self.preference = Item.Preference(preference) ?? .normal
        self.url = url
        self.imageURL = imageURL
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }

    func with(title: String? = nil, text: String? = nil) -> ItemValues {
        return ItemValues(
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

    static func valueValidations() throws -> ValueValidations<ItemValues> {
        var validations = ValueValidations(ItemValues.self)
        validations.add(\.title, "title",
            .count(Item.minimumLengthOfTitle...Item.maximumLengthOfTitle) &&
            .characterSet(
                .alphanumerics +
                .whitespaces +
                .punctuationCharacters
            )
        )
        validations.add(\.text, "text",
            .count(0...Item.maximumLengthOfText)
        )
        validations.add(\.url, "url",
            (.nil || .empty || (.url && .count(0...Item.maximumLengthOfURL)))
        )
        validations.add(\.imageURL, "imageURL",
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
    ) throws -> EventLoopFuture<ItemValues> {
        do {
            try validateValues()
        }
        catch let error as ValueValidationErrors<ItemValues> {
            return repository.future(
                error: ValuesError<ItemValues>
                    .validationFailed(on: error.failedKeyPaths, reason: error.reason)
            )
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
            return repository.future(self)
        }
    }

}

// MARK: -

extension Item {

    convenience init(for list: List, from data: ItemValues) throws {
        try self.init(title: Title(data.title), text: Text(data.text), list: list)
        if let urlString = data.url {
            self.url = URL(string: urlString)
        }
        else {
            self.url = nil
        }
        if let imageURLString = data.imageURL {
            self.imageURL = URL(string: imageURLString)
        }
        else {
            self.imageURL = nil
        }
    }

    func update(for list: List, from data: ItemValues) throws {
        guard listID == list.id else {
            throw EntityError<List>.requiredIDMismatch
        }
        title = Title(data.title)
        text = Text(data.text)
        preference = data.preference
        if let urlString = data.url {
            url = URL(string: urlString)
        }
        else {
            url = nil
        }
        if let imageURLString = data.imageURL {
            imageURL = URL(string: imageURLString)
        }
        else {
            imageURL = nil
        }
    }

}
