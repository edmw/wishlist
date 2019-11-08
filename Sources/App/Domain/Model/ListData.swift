import Vapor

/// Representation of a list with external properties only
/// and with simple types.
/// Used for validation, importing and exporting.
struct ListData: Content, Validatable, Reflectable {

    let title: String
    let visibility: Visibility
    let createdAt: Date?
    let modifiedAt: Date?
    let options: List.Options

    let itemsSorting: ItemsSorting?

    let items: [ItemData]?

    init(_ list: List, _ items: [Item]) {
        self.title = list.title
        self.visibility = list.visibility
        self.createdAt = list.createdAt
        self.modifiedAt = list.modifiedAt
        self.options = list.options

        self.itemsSorting = list.itemsSorting

        self.items = items.map { ItemData($0) }
    }

    init(
        title: String,
        visibility: Visibility,
        createdAt: Date?,
        modifiedAt: Date?,
        options: List.Options,
        itemsSorting: ItemsSorting? = nil,
        items: [ItemData]?
    ) {
        self.title = title
        self.visibility = visibility
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.options = options
        self.itemsSorting = itemsSorting
        self.items = items
    }

    func with(title: String? = nil, visibility: Visibility? = nil) -> ListData {
        return ListData(
            title: title ?? self.title,
            visibility: visibility ?? self.visibility,
            createdAt: self.createdAt,
            modifiedAt: self.modifiedAt,
            options: self.options,
            items: self.items
        )
    }

    // MARK: Validatable

    static func validations() throws -> Validations<ListData> {
        var validations = Validations(ListData.self)
        try validations.add(\.title,
            .count(List.minimumLengthOfTitle...List.maximumLengthOfTitle) &&
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
    ) throws -> EventLoopFuture<ListData> {
        do {
            try validate()
        }
        catch let error as ValidationError {
            var properties = [PartialKeyPath<List>]()
            // WORKAROUND: See https://github.com/vapor/validation/issues/26
            // This is a hack which parses the textual reason for an validation error.
            let reason = error.reason
            if reason.contains("'title'") {
                properties.append(\List.title)
            }
            if reason.contains("'visibility'") {
                properties.append(\List.visibility)
            }
            throw EntityError<List>.validationFailed(on: properties, reason: reason)
        }
        if let list = list {
            // validate against given list:
            // list id must exist
            guard let listID = list.id else {
                throw EntityError<List>.requiredIDMissing
            }
            return repository
                .find(by: listID)
                .unwrap(or: EntityError<List>.lookupFailed(for: listID))
                .transform(to: self)
        }
        else {
            // validate for new list:
            // list title must be unique
            return try repository
                .count(title: title, for: user)
                .null(or: EntityError<List>.uniquenessViolated(for: \List.title))
                .transform(to: self)
        }
    }

}

// MARK: -

extension List {

    convenience init(for user: User, from data: ListData) throws {
        try self.init(title: data.title, visibility: data.visibility, user: user)
    }

    func update(for user: User, from data: ListData) throws {
        guard userID == user.id else {
            throw EntityError<User>.requiredIDMismatch
        }
        title = data.title
        visibility = data.visibility
        options = data.options
        itemsSorting = data.itemsSorting
    }

}
