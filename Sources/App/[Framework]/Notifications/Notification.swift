import Vapor
import Leaf

// MARK: Notification

typealias NotificationTemplate = (name: String, context: AnyEncodable)

class Notification: CustomStringConvertible {

    typealias Message = (text: String, title: String)

    let user: User

    let title: String?
    let titleKey: String?
    // text
    let textTemplate: NotificationTemplate
    // html
    var htmlTemplate: NotificationTemplate?

    init(for user: User, title: String, templateName: String, templateContext: Encodable) {
        self.user = user
        self.title = title
        self.titleKey = nil
        self.textTemplate = (name: templateName, context: AnyEncodable(templateContext))
    }

    init(for user: User, titleKey: String, templateName: String, templateContext: Encodable) {
        self.user = user
        self.title = nil
        self.titleKey = titleKey
        self.textTemplate = (name: templateName, context: AnyEncodable(templateContext))
    }

    init(
        for user: User,
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
        for user: User,
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

    @discardableResult
    func send(
        on container: Container,
        at date: Date = Date(),
        before deadline: Date = .distantFuture
    ) throws
        -> EventLoopFuture<SendNotificationResult>
    {
        let job = SendNotificationJob(for: self, on: container, at: date, before: deadline)
        let jobService = try container.make(DispatchingService.self)
        return try jobService.dispatch(AnyJob(job))
            .transform(to: job.completed)
    }

    @discardableResult
    func dispatchSend(
        on container: Container,
        at date: Date = Date(),
        before deadline: Date = .distantFuture
    ) throws
        -> EventLoopFuture<Void>
    {
        let job = SendNotificationJob(for: self, on: container, at: date, before: deadline)
        let jobService = try container.make(DispatchingService.self)
        return try jobService.dispatch(AnyJob(job))
    }

    /// render text template
    func render(on container: Container) -> Future<Message> {
        return render(textTemplate, on: container)
    }

    /// render html template (fallback is text wrapped in <html>)
    func renderHTML(on container: Container) -> Future<Message> {
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

    func render(_ template: NotificationTemplate, on container: Container) -> Future<Message> {
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
                        throw NotificationError.templateInvalidEncoding
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
        return "Notification(\(user))"
    }

}
