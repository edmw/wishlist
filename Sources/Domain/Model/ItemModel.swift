import Foundation

public protocol ItemModel {

    var id: ItemID? { get }
    var title: Title { get }
    var text: Text { get }
    var preference: Item.Preference { get }
    var url: URL? { get }
    var imageURL: URL? { get }
    var createdAt: Date { get }
    var modifiedAt: Date { get }
    var archival: Bool { get }
    var localImageURL: ImageStoreLocator? { get }
    var listID: ListID { get }

    func isReserved(given reservation: ReservationModel?) -> Bool
    func isReceived(given reservation: ReservationModel?) -> Bool
    func deletable(given reservation: ReservationModel?) -> Bool
    func receivable(given reservation: ReservationModel?) -> Bool
    func archivable(given reservation: ReservationModel?) -> Bool
    func movable(given reservation: ReservationModel?) -> Bool
}

extension ItemModel {

    /// True, if the item with the given reservation is reserved.
    public func isReserved(given reservation: ReservationModel?) -> Bool {
        // item is reserved if there is reservation
        return reservation != nil
    }

    /// True, if the item with the given reservation is received.
    public func isReceived(given reservation: ReservationModel?) -> Bool {
        // item is received if there is reservation and reservation status is closed
        return reservation.map { reservation in reservation.status == .closed } ?? false
    }

    /// True, if the item with the given reservation can be deleted.
    public func deletable(given reservation: ReservationModel?) -> Bool {
        // item can be deleted if there is either no reservation or reservation status is closed
        return reservation.map { reservation in reservation.status == .closed } ?? true
    }

    /// True, if the item with the given reservation can be archived.
    public func archivable(given reservation: ReservationModel?) -> Bool {
        // item can be archived if there is either no reservation or reservation status is closed
        return archival == false
            && reservation.map { reservation in reservation.status == .closed } ?? true
    }

    /// True, if the item with the given reservation can be moved between lists.
    public func movable(given reservation: ReservationModel?) -> Bool {
        // item can be moved if there is either no reservation or reservation status is closed
        return reservation.map { reservation in reservation.status == .closed } ?? true
    }

    /// True, if the item with the given reservation can be received.
    public func receivable(given reservation: ReservationModel?) -> Bool {
        // item can be received if there is a reservation with status open
        return reservation.map { reservation in reservation.status == .open } ?? false
    }

}
