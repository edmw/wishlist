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
    var localImageURL: ImageStoreLocator? { get }
    var listID: ListID { get }

    func isDeletable(given reservation: ReservationModel?) -> Bool
    func isReceivable(given reservation: ReservationModel?) -> Bool
    func isArchivable(given reservation: ReservationModel?) -> Bool
    func isMovable(given reservation: ReservationModel?) -> Bool
}

extension ItemModel {

    /// True, if the item with the given reservation can be deleted.
    public func isDeletable(given reservation: ReservationModel?) -> Bool {
        // item can be deleted if there is no reservation
        return reservation == nil
    }

    /// True, if the item with the given reservation can be received.
    public func isReceivable(given reservation: ReservationModel?) -> Bool {
        // item can be received if there is a reservation with status open
        return reservation.map { reservation in reservation.status == .open } ?? false
    }

    /// True, if the item with the given reservation can be archived.
    public func isArchivable(given reservation: ReservationModel?) -> Bool {
        // item can be archived if there is either no reservation or if reservation status is closed
        return reservation.map { reservation in reservation.status == .closed } ?? true
    }

    /// True, if the item with the given reservation can be moved between lists.
    public func isMovable(given reservation: ReservationModel?) -> Bool {
        // item can be moved if there is either no reservation or if reservation status is closed
        return reservation.map { reservation in reservation.status == .closed } ?? true
    }

}
