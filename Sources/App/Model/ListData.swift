import Vapor

/// Representation of a list with external properties only
/// and with simple types.
/// Used for validation, importing and exporting.
struct ListData: Content, Validatable, Reflectable {

    let name: String
    let visibility: Visibility
    let createdAt: Date?
    let modifiedAt: Date?

    let itemsSorting: ItemsSorting?

    let items: [ItemData]?

    init(_ list: List, _ items: [Item]) {
        self.name = list.name
        self.visibility = list.visibility
        self.createdAt = list.createdAt
        self.modifiedAt = list.modifiedAt

        self.itemsSorting = list.itemsSorting

        self.items = items.map { ItemData($0) }
    }

    init(
        name: String,
        visibility: Visibility,
        createdAt: Date?,
        modifiedAt: Date?,
        itemsSorting: ItemsSorting? = nil,
        items: [ItemData]?
    ) {
        self.name = name
        self.visibility = visibility
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.itemsSorting = itemsSorting
        self.items = items
    }

    func with(name: String? = nil, visibility: Visibility? = nil) -> ListData {
        return ListData(
            name: name ?? self.name,
            visibility: visibility ?? self.visibility,
            createdAt: self.createdAt,
            modifiedAt: self.modifiedAt,
            items: self.items
        )
    }

    // MARK: Validatable

    static func validations() throws -> Validations<ListData> {
        var validations = Validations(ListData.self)
        try validations.add(\.name,
            .count(List.minimumLengthOfName...List.maximumLengthOfName) &&
            .characterSet(
                .alphanumerics +
                .whitespaces +
                .punctuationCharacters
            )
        )
        return validations
    }

    /// Validates the given list data on conformance to the constraints of the model.
    /// - Values must validate (see Validatable)
    /// - Name must be unique per user
    /// - When validating against a given list, the specified list must exist in the database.
    func validate(
        for user: User,
        this list: List? = nil,
        using repository: ListRepository
    ) throws -> Future<ListData> {
        do {
            try validate()
        }
        catch let error as ValidationError {
            var properties = [PartialKeyPath<List>]()
            // WORKAROUND: See https://github.com/vapor/validation/issues/26
            // This is a hack which parses the textual reason for an validation error.
            let reason = error.reason
            if reason.contains("'name'") {
                properties.append(\List.name)
            }
            if reason.contains("'visibility'") {
                properties.append(\List.visibility)
            }
            throw EntityError.validationFailed(on: properties, reason: reason)
        }
        if let list = list {
            // validate against given list:
            // list id must exist
            guard let listID = list.id else {
                throw ModelError<List>.requiredIDMissing
            }
            return repository
                .find(by: listID)
                .unwrap(or: EntityError<List>.lookupFailed(for: listID))
                .transform(to: self)
        }
        else {
            // validate for new list:
            // list name must be unique
            return try repository
                .find(name: name, for: user)
                .nil(or: EntityError<List>.uniquenessViolated(for: \List.name))
                .transform(to: self)
        }
    }

}

// MARK: -

extension List {

    convenience init(for user: User, from data: ListData) throws {
        try self.init(name: data.name, visibility: data.visibility, user: user)
    }

    func update(for user: User, from data: ListData) throws {
        guard userID == user.id else {
            throw ModelError<User>.requiredIDMismatch
        }
        name = data.name
        visibility = data.visibility
        itemsSorting = data.itemsSorting
    }

}
