import Vapor
import Leaf

final class InvitationMail: HTMLMessage, CustomStringConvertible {

    let invitation: Invitation

    init(_ invitation: Invitation) {
        self.invitation = invitation
    }

    // MARK: Message

    var emailRecipients: [EmailAddress] {
        return [EmailAddress(identifier: invitation.email)]
    }

    func renderHTML(on container: Container) -> EventLoopFuture<MessageContent> {
        return render("User/InvitationMail", on: container)
    }

    private func render(_ template: String, on container: Container)
        -> EventLoopFuture<MessageContent>
    {
        do {
            return try invitation.requireUser(on: container).flatMap { user in

                let title = try container.make(LocalizationService.self)
                    .localize("invitation-mail-title", for: user.language, on: container)

                let context = try InvitationMailContext(
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
                            throw InvitationMailError.templateInvalidEncoding
                        }
                        return (text: text, title: title ?? "🎁")
                    }
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
