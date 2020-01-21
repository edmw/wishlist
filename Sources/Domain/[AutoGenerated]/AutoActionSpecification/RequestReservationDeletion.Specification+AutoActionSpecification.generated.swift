// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import DomainModel

// MARK: RequestReservationDeletion.Specification

extension RequestReservationDeletion.Specification {

    public static func specification(
          userBy userid: UserID,
          itemBy itemid: ItemID,
          listBy listid: ListID,
          reservationBy reservationid: ReservationID
    ) -> Self {
        return Self(
            userID: userid,
            itemID: itemid,
            listID: listid,
            reservationID: reservationid
        )
    }

}
