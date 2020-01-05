import Domain

import Vapor
import Leaf

// MARK: UserNotification

typealias UserNotificationTemplate = (name: String, context: AnyEncodable)

class UserNotification: MultiMessage, CustomStringConvertible {

    let user: UserRepresentation

    let title: String?
    let titleKey: String?
    // text
    let textTemplate: UserNotificationTemplate
    // html
    var htmlTemplate: UserNotificationTemplate?

    var emailRecipients = [EmailAddress]()

    var pushoverRecipients = [PushoverUser]()

    init(
        for user: UserRepresentation,
        title: String,
        templateName: String,
        templateContext: Encodable
    ) {
        self.user = user
        self.title = title
        self.titleKey = nil
        self.textTemplate = (name: templateName, context: AnyEncodable(templateContext))
    }

    init(
        for user: UserRepresentation,
        titleKey: String,
        templateName: String,
        templateContext: Encodable
    ) {
        self.user = user
        self.title = nil
        self.titleKey = titleKey
        self.textTemplate = (name: templateName, context: AnyEncodable(templateContext))
    }

    init(
        for user: UserRepresentation,
        title: String,
        templateName: String,
        templateContext: Encodable,
        htmlTemplateName: String,
        htmlTemplateContext: Encodable
    ) {
        self.user = user
        self.title = title
        self.titleKey = nil
        self.textTemplate = (name: templateName, context: AnyEncodable(templateContext))
        self.htmlTemplate = (name: htmlTemplateName, context: AnyEncodable(htmlTemplateContext))
    }

    init(
        for user: UserRepresentation,
        titleKey: String,
        templateName: String,
        templateContext: Encodable,
        htmlTemplateName: String,
        htmlTemplateContext: Encodable
    ) {
        self.user = user
        self.title = nil
        self.titleKey = titleKey
        self.textTemplate = (name: templateName, context: AnyEncodable(templateContext))
        self.htmlTemplate = (name: htmlTemplateName, context: AnyEncodable(htmlTemplateContext))
    }

    // MARK: Message

    /// render text template
    func render(on container: Container) -> EventLoopFuture<MessageContent> {
        return render(textTemplate, on: container)
    }

    /// render html template (fallback is text wrapped in <html>)
    func renderHTML(on container: Container) -> EventLoopFuture<MessageContent> {
        if let htmlTemplate = htmlTemplate {
            return render(htmlTemplate, on: container)
        }
        else {
            // fallback
            return render(textTemplate, on: container)
                .map { message in
                    return (text: "<html>\(message.text)</html>", title: message.title)
                }
        }
    }

    private func render(_ template: UserNotificationTemplate, on container: Container)
        -> EventLoopFuture<MessageContent>
    {
        do {
            var title = self.title
            if title == nil, let titleKey = titleKey {
                title = try container.make(LocalizationService.self)
                    .localize(titleKey, for: user.language, on: container)
            }
            return try container.make(LeafRenderer.self)
                .render(
                    template.name,
                    template.context,
                    userInfo: [ "language": user.language ?? ""]
                )
                .map { view in
                    guard let text = String(data: view.data, encoding: .utf8) else {
                        throw UserNotificationError.templateInvalidEncoding
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
        return "UserNotification(\(user))"
    }

}
