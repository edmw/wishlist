import Foundation
import NIO

// MARK: ListValues

/// Representation of a list with external properties and basic types, only.
/// Used for validation, importing and exporting.
public struct ListValues: Values, ValueValidatable {

    public var title: String
    public var visibility: String
    public var createdAt: Date?
    public var modifiedAt: Date?
    public var options: String?

    public var itemsSorting: String?

    public var items: [ItemValues]?

    public var itemsCount: Int?

    public var ownerName: String?

    /// Creates list values from the model types.
    init(_ list: List, _ items: [Item]? = nil) {
        self.title = String(list.title)
        self.visibility = String(list.visibility)
        self.createdAt = list.createdAt
        self.modifiedAt = list.modifiedAt
        self.options = String(list.options)

        self.itemsSorting = list.itemsSorting.flatMap(String.init)

        self.items = items?.map { ItemValues($0) }
        self.itemsCount = items?.count
    }

    /// Creates list values from partital list values.
    init(_ values: PartialValues<ListValues>) throws {
        self.title = try values.value(for: \.title)
        self.visibility = try values.value(for: \.visibility)
        self.createdAt = values[\.createdAt]
        self.modifiedAt = values[\.modifiedAt]
        self.options = values[\.options]

        self.itemsSorting = values[\.itemsSorting]
    }

    /// Creates list values from individual list values.
    init(
        title: Title,
        visibility: Visibility,
        createdAt: Date?,
        modifiedAt: Date?,
        options: List.Options,
        itemsSorting: ItemsSorting? = nil,
        items: [ItemValues]?
    ) {
        self.title = String(title)
        self.visibility = String(visibility)
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.options = String(options)
        self.itemsSorting = itemsSorting.map { String($0) }
        self.items = items
        self.itemsCount = items?.count
    }

    /// Creates list values from simple data types. For example from user input.
    public init(
        title: String,
        visibility: String,
        createdAt: Date?,
        modifiedAt: Date?,
        options: String? = nil,
        maskReservations: Bool? = nil,
        itemsSorting: String? = nil,
        items: [ItemValues]?
    ) {
        self.title = title
        self.visibility = visibility
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        var options = options.flatMap(List.Options.init(string:)) ?? []
        if let maskReservations = maskReservations {
            if maskReservations == true {
                options = options.union([.maskReservations])
            }
            else {
                options = options.subtracting([.maskReservations])
            }
        }
        self.options = String(options)
        self.itemsSorting = itemsSorting
        self.items = items
        self.itemsCount = items?.count
    }

    func with(title: Title? = nil, visibility: Visibility? = nil) -> ListValues {
        return ListValues(
            title: title.flatMap(String.init) ?? self.title,
            visibility: visibility.flatMap(String.init) ?? self.visibility,
            createdAt: self.createdAt,
            modifiedAt: self.modifiedAt,
            options: self.options,
            items: self.items
        )
    }

    // MARK: Validatable

    static func valueValidations() throws -> ValueValidations<ListValues> {
        var validations = ValueValidations(ListValues.self)
        validations.add(\.title, "title",
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
    ) throws -> EventLoopFuture<ListValues> {
        do {
            try validateValues()
        }
        catch let error as ValueValidationErrors<ListValues> {
            return repository.future(
                error: ValuesError<ListValues>
                    .validationFailed(on: error.failedKeyPaths, reason: error.reason)
            )
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
            let title = Title(self.title)
            return try repository
                .count(title: title, for: user)
                .null(or: ValuesError<ListValues>.uniquenessViolated(for: \ListValues.title))
                .transform(to: self)
        }
    }

}

// MARK: -

extension List {

    convenience init(for user: User, from data: ListValues) throws {
        try self.init(
            title: Title(data.title),
            visibility: Visibility(data.visibility) ?? .´private´,
            user: user
        )
    }

    func update(for user: User, from data: ListValues) throws {
        guard userID == user.id else {
            throw EntityError<User>.requiredIDMismatch
        }
        title = Title(data.title)
        visibility = Visibility(data.visibility) ?? .´private´
        options = data.options.flatMap(List.Options.init(string:)) ?? []
        itemsSorting = data.itemsSorting.flatMap { ItemsSorting($0) }
    }

}
