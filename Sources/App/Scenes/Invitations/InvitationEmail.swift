import Domain

import Vapor
import Leaf

final class InvitationEmail: HTMLMessage, CustomStringConvertible {

    let invitation: InvitationRepresentation
    let user: UserRepresentation

    init(for invitation: InvitationRepresentation, invitedBy user: UserRepresentation) {
        self.invitation = invitation
        self.user = user
    }

    // MARK: Message

    var emailRecipients = [EmailAddress]()

    func renderHTML(on container: Container) -> EventLoopFuture<MessageContent> {
        return render("User/InvitationMail", on: container)
    }

    private func render(_ template: String, on container: Container)
        -> EventLoopFuture<MessageContent>
    {
        do {
            let title = try container.make(LocalizationService.self)
                .localize("invitation-mail-title", for: user.language, on: container)

            let context = try InvitationEmailContext(
                for: self.invitation,
                from: user,
                on: container.site()
            )

            return try container.make(LeafRenderer.self)
                .render(
                    template,
                    context,
                    userInfo: [ "language": user.language ?? ""]
                )
                .map { view in
                    guard let text = String(data: view.data, encoding: .utf8) else {
                        throw InvitationEmailError.templateInvalidEncoding
                    }
                    return (text: text, title: title ?? "🎁")
                }
        }
        catch {
            return container.future(error: error)
        }
    }

    // MARK: CustomStringConvertible

    var description: String {
        return "InvitationMail(\(invitation))"
    }

}

// MARK: -

extension VaporEmailSendingProvider {

    func sendInvitationEmail(_ invitation: InvitationRepresentation, for user: UserRepresentation)
        throws -> EventLoopFuture<Bool>
    {
        var email = InvitationEmail(for: invitation, invitedBy: user)
        email.addEmailRecipient(EmailAddress(identifier: String(invitation.email)))
        return try email.send(on: request)
            .map { sendResult in sendResult.success == true }
    }

}
