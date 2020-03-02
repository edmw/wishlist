// sourcery:inline:ActionSpecification.AutoActionSpecification
// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: DO NOT EDIT
import Foundation

// MARK: CreateFavorite.Specification

extension CreateFavorite.Specification {

    public static func specification(
          userBy userid: UserID,
          listBy listid: ListID
    ) -> Self {
        return Self(
            userID: userid,
            listID: listid
        )
    }

}

// MARK: CreateInvitation.Specification

extension CreateInvitation.Specification {

    public static func specification(
          userBy userid: UserID,
          from values: InvitationValues,
          sendEmail sendemail: Bool
    ) -> Self {
        return Self(
            userID: userid,
            values: values,
            sendEmail: sendemail
        )
    }

}

// MARK: CreateItem.Specification

extension CreateItem.Specification {

    public static func specification(
          userBy userid: UserID,
          listBy listid: ListID,
          from values: ItemValues
    ) -> Self {
        return Self(
            userID: userid,
            listID: listid,
            values: values
        )
    }

}

// MARK: CreateList.Specification

extension CreateList.Specification {

    public static func specification(
          userBy userid: UserID,
          from values: ListValues
    ) -> Self {
        return Self(
            userID: userid,
            values: values
        )
    }

}

// MARK: CreateOrUpdateItem.Specification

extension CreateOrUpdateItem.Specification {

    public static func specification(
          userBy userid: UserID,
          listBy listid: ListID,
          itemBy itemid: ItemID?,
          from values: ItemValues
    ) -> Self {
        return Self(
            userID: userid,
            listID: listid,
            itemID: itemid,
            values: values
        )
    }

}

// MARK: CreateOrUpdateList.Specification

extension CreateOrUpdateList.Specification {

    public static func specification(
          userBy userid: UserID,
          listBy listid: ListID?,
          from values: ListValues
    ) -> Self {
        return Self(
            userID: userid,
            listID: listid,
            values: values
        )
    }

}

// MARK: DeleteFavorite.Specification

extension DeleteFavorite.Specification {

    public static func specification(
          userBy userid: UserID,
          listBy listid: ListID
    ) -> Self {
        return Self(
            userID: userid,
            listID: listid
        )
    }

}

// MARK: DeleteItem.Specification

extension DeleteItem.Specification {

    public static func specification(
          userBy userid: UserID,
          listBy listid: ListID,
          itemBy itemid: ItemID
    ) -> Self {
        return Self(
            userID: userid,
            listID: listid,
            itemID: itemid
        )
    }

}

// MARK: DeleteList.Specification

extension DeleteList.Specification {

    public static func specification(
          userBy userid: UserID,
          listBy listid: ListID
    ) -> Self {
        return Self(
            userID: userid,
            listID: listid
        )
    }

}

// MARK: DeleteReservation.Specification

extension DeleteReservation.Specification {

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

// MARK: ExportListToJSON.Specification

extension ExportListToJSON.Specification {

    public static func specification(
          userBy userid: UserID,
          listBy listid: ListID
    ) -> Self {
        return Self(
            userID: userid,
            listID: listid
        )
    }

}

// MARK: GetInvitations.Specification

extension GetInvitations.Specification {

    public static func specification(
          userBy userid: UserID
    ) -> Self {
        return Self(
            userID: userid
        )
    }

}

// MARK: GetItems.Specification

extension GetItems.Specification {

    public static func specification(
          userBy userid: UserID,
          listBy listid: ListID,
          with sorting: ItemsSorting?
    ) -> Self {
        return Self(
            userID: userid,
            listID: listid,
            sorting: sorting
        )
    }

}

// MARK: GetListsAndFavorites.Specification

extension GetListsAndFavorites.Specification {

    public static func specification(
          userBy userid: UserID
    ) -> Self {
        return Self(
            userID: userid
        )
    }

}

// MARK: GetProfileAndInvitations.Specification

extension GetProfileAndInvitations.Specification {

    public static func specification(
          userBy userid: UserID
    ) -> Self {
        return Self(
            userID: userid
        )
    }

}

// MARK: ImportListFromJSON.Specification

extension ImportListFromJSON.Specification {

    public static func specification(
          userBy userid: UserID,
          json: String
    ) -> Self {
        return Self(
            userID: userid,
            json: json
        )
    }

}

// MARK: MaterialiseUser.Specification

extension MaterialiseUser.Specification {

    public static func specification(
          options: MaterialiseUser.Options,
          userIdentity useridentity: UserIdentity,
          userIdentityProvider useridentityprovider: UserIdentityProvider,
          userValues uservalues: PartialValues<UserValues>,
          invitationCode invitationcode: InvitationCode?,
          guestIdentification guestidentification: Identification?
    ) -> Self {
        return Self(
            options: options,
            userIdentity: useridentity,
            userIdentityProvider: useridentityprovider,
            userValues: uservalues,
            invitationCode: invitationcode,
            guestIdentification: guestidentification
        )
    }

}

// MARK: MoveItem.Specification

extension MoveItem.Specification {

    public static func specification(
          userBy userid: UserID,
          listBy listid: ListID,
          itemBy itemid: ItemID,
          targetListID targetlistid: ListID
    ) -> Self {
        return Self(
            userID: userid,
            listID: listid,
            itemID: itemid,
            targetListID: targetlistid
        )
    }

}

// MARK: PresentPublicly.Specification

extension PresentPublicly.Specification {

    public static func specification(
          userBy userid: UserID?
    ) -> Self {
        return Self(
            userID: userid
        )
    }

}

// MARK: RequestFavoriteCreation.Specification

extension RequestFavoriteCreation.Specification {

    public static func specification(
          userBy userid: UserID,
          listBy listid: ListID
    ) -> Self {
        return Self(
            userID: userid,
            listID: listid
        )
    }

}

// MARK: RequestFavoriteDeletion.Specification

extension RequestFavoriteDeletion.Specification {

    public static func specification(
          userBy userid: UserID,
          listBy listid: ListID
    ) -> Self {
        return Self(
            userID: userid,
            listID: listid
        )
    }

}

// MARK: RequestInvitationCreation.Specification

extension RequestInvitationCreation.Specification {

    public static func specification(
          userBy userid: UserID
    ) -> Self {
        return Self(
            userID: userid
        )
    }

}

// MARK: RequestInvitationRevocation.Specification

extension RequestInvitationRevocation.Specification {

    public static func specification(
          userBy userid: UserID,
          invitationBy invitationid: InvitationID
    ) -> Self {
        return Self(
            userID: userid,
            invitationID: invitationid
        )
    }

}

// MARK: RequestItemDeletion.Specification

extension RequestItemDeletion.Specification {

    public static func specification(
          userBy userid: UserID,
          listBy listid: ListID,
          itemBy itemid: ItemID
    ) -> Self {
        return Self(
            userID: userid,
            listID: listid,
            itemID: itemid
        )
    }

}

// MARK: RequestItemEditing.Specification

extension RequestItemEditing.Specification {

    public static func specification(
          userBy userid: UserID,
          listBy listid: ListID,
          itemBy itemid: ItemID?
    ) -> Self {
        return Self(
            userID: userid,
            listID: listid,
            itemID: itemid
        )
    }

}

// MARK: RequestItemMovement.Specification

extension RequestItemMovement.Specification {

    public static func specification(
          userBy userid: UserID,
          listBy listid: ListID,
          itemBy itemid: ItemID
    ) -> Self {
        return Self(
            userID: userid,
            listID: listid,
            itemID: itemid
        )
    }

}

// MARK: RequestListDeletion.Specification

extension RequestListDeletion.Specification {

    public static func specification(
          userBy userid: UserID,
          listBy listid: ListID
    ) -> Self {
        return Self(
            userID: userid,
            listID: listid
        )
    }

}

// MARK: RequestListEditing.Specification

extension RequestListEditing.Specification {

    public static func specification(
          userBy userid: UserID,
          listBy listid: ListID?
    ) -> Self {
        return Self(
            userID: userid,
            listID: listid
        )
    }

}

// MARK: RequestListImportFromJSON.Specification

extension RequestListImportFromJSON.Specification {

    public static func specification(
          userBy userid: UserID
    ) -> Self {
        return Self(
            userID: userid
        )
    }

}

// MARK: RequestProfileEditing.Specification

extension RequestProfileEditing.Specification {

    public static func specification(
          userBy userid: UserID
    ) -> Self {
        return Self(
            userID: userid
        )
    }

}

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

// MARK: RequestSettingsEditing.Specification

extension RequestSettingsEditing.Specification {

    public static func specification(
          userBy userid: UserID
    ) -> Self {
        return Self(
            userID: userid
        )
    }

}

// MARK: RevokeInvitation.Specification

extension RevokeInvitation.Specification {

    public static func specification(
          userBy userid: UserID,
          invitationBy invitationid: InvitationID
    ) -> Self {
        return Self(
            userID: userid,
            invitationID: invitationid
        )
    }

}

// MARK: TestNotifications.Specification

extension TestNotifications.Specification {

    public static func specification(
          userBy userid: UserID
    ) -> Self {
        return Self(
            userID: userid
        )
    }

}

// MARK: UpdateItem.Specification

extension UpdateItem.Specification {

    public static func specification(
          userBy userid: UserID,
          listBy listid: ListID,
          itemBy itemid: ItemID,
          from values: ItemValues
    ) -> Self {
        return Self(
            userID: userid,
            listID: listid,
            itemID: itemid,
            values: values
        )
    }

}

// MARK: UpdateList.Specification

extension UpdateList.Specification {

    public static func specification(
          userBy userid: UserID,
          listBy listid: ListID,
          from values: ListValues
    ) -> Self {
        return Self(
            userID: userid,
            listID: listid,
            values: values
        )
    }

}

// MARK: UpdateProfile.Specification

extension UpdateProfile.Specification {

    public static func specification(
          userBy userid: UserID,
          from values: PartialValues<UserValues>
    ) -> Self {
        return Self(
            userID: userid,
            values: values
        )
    }

}

// MARK: UpdateSettings.Specification

extension UpdateSettings.Specification {

    public static func specification(
          userBy userid: UserID,
          from values: PartialValues<UserSettings>
    ) -> Self {
        return Self(
            userID: userid,
            values: values
        )
    }

}
// sourcery:end
