import Domain
import Library

import Vapor
import Leaf

// MARK: UserNotification

private typealias UserNotificationTemplate = (name: String, context: AnyEncodable)

class UserNotification: MultiMessage, CustomStringConvertible {

    private let user: UserRepresentation

    private let title: String?
    private let titleKey: String?
    // text
    private let textTemplate: UserNotificationTemplate
    // html
    private var htmlTemplate: UserNotificationTemplate?

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
                    return .init(text: "<html>\(message.text)</html>", title: message.title)
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
                    return .init(text: text, title: title ?? "🎁")
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

// MARK: AnyEncodable

/// The simplest implementation of an `AnyEncodable`. This is used instead of the better version
/// provided by Library because Vapors `TemplateDataEncoder` implements an incomplete
/// `SingleValueEncodingContainer` only. Downside is, this doesn‘t respect any encoding strategies.
private struct AnyEncodable: Encodable {

    let encodable: Encodable

    init(_ encodable: Encodable) {
        self.encodable = encodable
    }

    func encode(to encoder: Encoder) throws {
        try self.encodable.encode(to: encoder)
    }

}
