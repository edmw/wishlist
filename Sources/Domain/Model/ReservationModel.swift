import Foundation

public protocol ReservationModel {
    var id: UUID? { get }
    var createdAt: Date { get }
    var itemID: UUID { get }
    var holder: Identification { get }
}
