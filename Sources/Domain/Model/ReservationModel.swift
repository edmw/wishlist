import Foundation

public protocol ReservationModel {
    var id: ReservationID? { get }
    var status: Reservation.Status { get }
    var createdAt: Date { get }
    var itemID: ItemID { get }
    var holder: Identification { get }
}
