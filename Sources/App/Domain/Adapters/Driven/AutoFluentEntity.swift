import Domain

protocol AutoFluentEntity where Self: Entity {
}

// sourcery: AutoFluentEntityPivot
// sourcery: AutoFluentEntityPivotLeft = User
// sourcery: AutoFluentEntityPivotRight = List
extension Favorite: AutoFluentEntity {}

// sourcery: AutoFluentEntityUniqueFields = code
// sourcery: AutoFluentEntityParent = User
// sourcery: AutoFluentEntityRelation = Invitee
extension Invitation: AutoFluentEntity {}

// sourcery: AutoFluentEntityParent = List
// sourcery: AutoFluentEntityParentOnDeleteCascade
extension Item: AutoFluentEntity {}

// sourcery: AutoFluentEntityParent = User
// sourcery: AutoFluentEntityParentOnDeleteCascade
// sourcery: AutoFluentEntityChildren = Item
extension List: AutoFluentEntity {}

// sourcery: AutoFluentEntityParent = Item
// sourcery: AutoFluentEntityParentOnDeleteCascade
extension Reservation: AutoFluentEntity {}

// sourcery: AutoFluentEntityUniqueFields = identification
// sourcery: AutoFluentEntityChildren = List
extension User: AutoFluentEntity {}
