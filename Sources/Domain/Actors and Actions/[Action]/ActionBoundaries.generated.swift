// sourcery:inline:ActionBoundaries.AutoActionBoundaries
// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: DO NOT EDIT

import Foundation
import NIO

// MARK: AddReservationToItem.Boundaries

extension AddReservationToItem.Boundaries {

    public static func boundaries(
        worker: EventLoop,
        notificationSending notificationsending: NotificationSendingProvider
    ) -> Self {
        return Self(
            worker: worker,
            notificationSending: notificationsending
        )
    }

}
// MARK: CreateFavorite.Boundaries

extension CreateFavorite.Boundaries {

    public static func boundaries(
        worker: EventLoop
    ) -> Self {
        return Self(
            worker: worker
        )
    }

}
// MARK: CreateInvitation.Boundaries

extension CreateInvitation.Boundaries {

    public static func boundaries(
        worker: EventLoop,
        emailSending emailsending: EmailSendingProvider
    ) -> Self {
        return Self(
            worker: worker,
            emailSending: emailsending
        )
    }

}
// MARK: CreateItem.Boundaries

extension CreateItem.Boundaries {

    public static func boundaries(
        worker: EventLoop,
        imageStore imagestore: ImageStoreProvider
    ) -> Self {
        return Self(
            worker: worker,
            imageStore: imagestore
        )
    }

}
// MARK: CreateList.Boundaries

extension CreateList.Boundaries {

    public static func boundaries(
        worker: EventLoop
    ) -> Self {
        return Self(
            worker: worker
        )
    }

}
// MARK: CreateOrUpdateItem.Boundaries

extension CreateOrUpdateItem.Boundaries {

    public static func boundaries(
        worker: EventLoop,
        imageStore imagestore: ImageStoreProvider
    ) -> Self {
        return Self(
            worker: worker,
            imageStore: imagestore
        )
    }

}
// MARK: CreateOrUpdateList.Boundaries

extension CreateOrUpdateList.Boundaries {

    public static func boundaries(
        worker: EventLoop
    ) -> Self {
        return Self(
            worker: worker
        )
    }

}
// MARK: DeleteFavorite.Boundaries

extension DeleteFavorite.Boundaries {

    public static func boundaries(
        worker: EventLoop
    ) -> Self {
        return Self(
            worker: worker
        )
    }

}
// MARK: DeleteItem.Boundaries

extension DeleteItem.Boundaries {

    public static func boundaries(
        worker: EventLoop,
        imageStore imagestore: ImageStoreProvider
    ) -> Self {
        return Self(
            worker: worker,
            imageStore: imagestore
        )
    }

}
// MARK: DeleteList.Boundaries

extension DeleteList.Boundaries {

    public static func boundaries(
        worker: EventLoop,
        imageStore imagestore: ImageStoreProvider
    ) -> Self {
        return Self(
            worker: worker,
            imageStore: imagestore
        )
    }

}
// MARK: DeleteReservation.Boundaries

extension DeleteReservation.Boundaries {

    public static func boundaries(
        worker: EventLoop
    ) -> Self {
        return Self(
            worker: worker
        )
    }

}
// MARK: ExportListToJSON.Boundaries

extension ExportListToJSON.Boundaries {

    public static func boundaries(
        worker: EventLoop
    ) -> Self {
        return Self(
            worker: worker
        )
    }

}
// MARK: GetFavorites.Boundaries

extension GetFavorites.Boundaries {

    public static func boundaries(
        worker: EventLoop
    ) -> Self {
        return Self(
            worker: worker
        )
    }

}
// MARK: GetInvitations.Boundaries

extension GetInvitations.Boundaries {

    public static func boundaries(
        worker: EventLoop
    ) -> Self {
        return Self(
            worker: worker
        )
    }

}
// MARK: GetItems.Boundaries

extension GetItems.Boundaries {

    public static func boundaries(
        worker: EventLoop
    ) -> Self {
        return Self(
            worker: worker
        )
    }

}
// MARK: GetLists.Boundaries

extension GetLists.Boundaries {

    public static func boundaries(
        worker: EventLoop
    ) -> Self {
        return Self(
            worker: worker
        )
    }

}
// MARK: GetListsAndFavorites.Boundaries

extension GetListsAndFavorites.Boundaries {

    public static func boundaries(
        worker: EventLoop
    ) -> Self {
        return Self(
            worker: worker
        )
    }

}
// MARK: GetProfileAndInvitations.Boundaries

extension GetProfileAndInvitations.Boundaries {

    public static func boundaries(
        worker: EventLoop
    ) -> Self {
        return Self(
            worker: worker
        )
    }

}
// MARK: ImportListFromJSON.Boundaries

extension ImportListFromJSON.Boundaries {

    public static func boundaries(
        worker: EventLoop,
        imageStore imagestore: ImageStoreProvider
    ) -> Self {
        return Self(
            worker: worker,
            imageStore: imagestore
        )
    }

}
// MARK: MaterialiseUser.Boundaries

extension MaterialiseUser.Boundaries {

    public static func boundaries(
        worker: EventLoop
    ) -> Self {
        return Self(
            worker: worker
        )
    }

}
// MARK: MoveItem.Boundaries

extension MoveItem.Boundaries {

    public static func boundaries(
        worker: EventLoop
    ) -> Self {
        return Self(
            worker: worker
        )
    }

}
// MARK: PresentPublicly.Boundaries

extension PresentPublicly.Boundaries {

    public static func boundaries(
        worker: EventLoop
    ) -> Self {
        return Self(
            worker: worker
        )
    }

}
// MARK: PresentReservation.Boundaries

extension PresentReservation.Boundaries {

    public static func boundaries(
        worker: EventLoop
    ) -> Self {
        return Self(
            worker: worker
        )
    }

}
// MARK: PresentWishlist.Boundaries

extension PresentWishlist.Boundaries {

    public static func boundaries(
        worker: EventLoop
    ) -> Self {
        return Self(
            worker: worker
        )
    }

}
// MARK: RemoveReservationFromItem.Boundaries

extension RemoveReservationFromItem.Boundaries {

    public static func boundaries(
        worker: EventLoop,
        notificationSending notificationsending: NotificationSendingProvider
    ) -> Self {
        return Self(
            worker: worker,
            notificationSending: notificationsending
        )
    }

}
// MARK: RequestFavoriteCreation.Boundaries

extension RequestFavoriteCreation.Boundaries {

    public static func boundaries(
        worker: EventLoop
    ) -> Self {
        return Self(
            worker: worker
        )
    }

}
// MARK: RequestFavoriteDeletion.Boundaries

extension RequestFavoriteDeletion.Boundaries {

    public static func boundaries(
        worker: EventLoop
    ) -> Self {
        return Self(
            worker: worker
        )
    }

}
// MARK: RequestInvitationCreation.Boundaries

extension RequestInvitationCreation.Boundaries {

    public static func boundaries(
        worker: EventLoop
    ) -> Self {
        return Self(
            worker: worker
        )
    }

}
// MARK: RequestInvitationRevocation.Boundaries

extension RequestInvitationRevocation.Boundaries {

    public static func boundaries(
        worker: EventLoop
    ) -> Self {
        return Self(
            worker: worker
        )
    }

}
// MARK: RequestItemDeletion.Boundaries

extension RequestItemDeletion.Boundaries {

    public static func boundaries(
        worker: EventLoop
    ) -> Self {
        return Self(
            worker: worker
        )
    }

}
// MARK: RequestItemEditing.Boundaries

extension RequestItemEditing.Boundaries {

    public static func boundaries(
        worker: EventLoop
    ) -> Self {
        return Self(
            worker: worker
        )
    }

}
// MARK: RequestItemMovement.Boundaries

extension RequestItemMovement.Boundaries {

    public static func boundaries(
        worker: EventLoop
    ) -> Self {
        return Self(
            worker: worker
        )
    }

}
// MARK: RequestListDeletion.Boundaries

extension RequestListDeletion.Boundaries {

    public static func boundaries(
        worker: EventLoop
    ) -> Self {
        return Self(
            worker: worker
        )
    }

}
// MARK: RequestListEditing.Boundaries

extension RequestListEditing.Boundaries {

    public static func boundaries(
        worker: EventLoop
    ) -> Self {
        return Self(
            worker: worker
        )
    }

}
// MARK: RequestListImportFromJSON.Boundaries

extension RequestListImportFromJSON.Boundaries {

    public static func boundaries(
        worker: EventLoop
    ) -> Self {
        return Self(
            worker: worker
        )
    }

}
// MARK: RequestProfileEditing.Boundaries

extension RequestProfileEditing.Boundaries {

    public static func boundaries(
        worker: EventLoop
    ) -> Self {
        return Self(
            worker: worker
        )
    }

}
// MARK: RequestReservationDeletion.Boundaries

extension RequestReservationDeletion.Boundaries {

    public static func boundaries(
        worker: EventLoop
    ) -> Self {
        return Self(
            worker: worker
        )
    }

}
// MARK: RequestSettingsEditing.Boundaries

extension RequestSettingsEditing.Boundaries {

    public static func boundaries(
        worker: EventLoop
    ) -> Self {
        return Self(
            worker: worker
        )
    }

}
// MARK: RevokeInvitation.Boundaries

extension RevokeInvitation.Boundaries {

    public static func boundaries(
        worker: EventLoop
    ) -> Self {
        return Self(
            worker: worker
        )
    }

}
// MARK: SendInvitationEmail.Boundaries

extension SendInvitationEmail.Boundaries {

    public static func boundaries(
        worker: EventLoop,
        emailSending emailsending: EmailSendingProvider
    ) -> Self {
        return Self(
            worker: worker,
            emailSending: emailsending
        )
    }

}
// MARK: TestNotifications.Boundaries

extension TestNotifications.Boundaries {

    public static func boundaries(
        worker: EventLoop,
        notificationSending notificationsending: NotificationSendingProvider
    ) -> Self {
        return Self(
            worker: worker,
            notificationSending: notificationsending
        )
    }

}
// MARK: UpdateItem.Boundaries

extension UpdateItem.Boundaries {

    public static func boundaries(
        worker: EventLoop,
        imageStore imagestore: ImageStoreProvider
    ) -> Self {
        return Self(
            worker: worker,
            imageStore: imagestore
        )
    }

}
// MARK: UpdateList.Boundaries

extension UpdateList.Boundaries {

    public static func boundaries(
        worker: EventLoop
    ) -> Self {
        return Self(
            worker: worker
        )
    }

}
// MARK: UpdateProfile.Boundaries

extension UpdateProfile.Boundaries {

    public static func boundaries(
        worker: EventLoop
    ) -> Self {
        return Self(
            worker: worker
        )
    }

}
// MARK: UpdateSettings.Boundaries

extension UpdateSettings.Boundaries {

    public static func boundaries(
        worker: EventLoop
    ) -> Self {
        return Self(
            worker: worker
        )
    }

}
// sourcery:end
