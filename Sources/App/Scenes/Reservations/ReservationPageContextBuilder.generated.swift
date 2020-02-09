// sourcery:inline:ReservationPageContextBuilder.AutoPageContextBuilder

// MARK: DO NOT EDIT

import Domain

import Foundation

// MARK: ReservationPageContext

extension ReservationPageContext {

    static var builder: ReservationPageContextBuilder {
        return ReservationPageContextBuilder()
    }
}

enum ReservationPageContextBuilderError: Error {
  case missingRequiredIdentification
  case missingRequiredItem
  case missingRequiredList
}

class ReservationPageContextBuilder {

    var identification: Identification?
    var item: ItemRepresentation?
    var list: ListRepresentation?
    var reservation: ReservationRepresentation?
    var user: UserRepresentation?

    @discardableResult
    func forIdentification(_ identification: Identification) -> Self {
        self.identification = identification
        return self
    }

    @discardableResult
    func forItem(_ item: ItemRepresentation) -> Self {
        self.item = item
        return self
    }

    @discardableResult
    func forList(_ list: ListRepresentation) -> Self {
        self.list = list
        return self
    }

    @discardableResult
    func withReservation(_ reservation: ReservationRepresentation?) -> Self {
        self.reservation = reservation
        return self
    }

    @discardableResult
    func withUser(_ user: UserRepresentation?) -> Self {
        self.user = user
        return self
    }

    func build() throws -> ReservationPageContext {
        guard let identification = identification else {
            throw ReservationPageContextBuilderError.missingRequiredIdentification
        }
        guard let item = item else {
            throw ReservationPageContextBuilderError.missingRequiredItem
        }
        guard let list = list else {
            throw ReservationPageContextBuilderError.missingRequiredList
        }
        return .init(
            for: identification,
            and: item,
            in: list,
            with: reservation,
            user: user
        )
    }

}
// sourcery:end
