import Domain

// MARK: AutoContext

// Code for contexts will be generated.
protocol AutoContext {
}

protocol AutoRepresentationContext: AutoContext {
}

extension ItemRepresentation: AutoRepresentationContext {}
extension ListRepresentation: AutoRepresentationContext {}
extension FavoriteRepresentation: AutoRepresentationContext {}
extension InvitationRepresentation: AutoRepresentationContext {}
