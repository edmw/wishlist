import Vapor
import Leaf

// MARK: Notification

class Notification: CustomStringConvertible {

    typealias Message = (text: String, title: String)

    let user: User

    let title: String?
    let titleKey: String?
    let templateName: String
    let templateContext: AnyEncodable

    init(for user: User, title: String, templateName: String, templateContext: Encodable) {
        self.user = user
        self.title = title
        self.titleKey = nil
        self.templateName = templateName
        self.templateContext = AnyEncodable(templateContext)
    }

    init(for user: User, titleKey: String, templateName: String, templateContext: Encodable) {
        self.user = user
        self.title = nil
        self.titleKey = titleKey
        self.templateName = templateName
        self.templateContext = AnyEncodable(templateContext)
    }

    @discardableResult
    func dispatchSend(
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

    func render(on container: Container) -> Future<Message> {
        do {
            var title = self.title
            if title == nil, let titleKey = titleKey {
                title = try container.make(LocalizationService.self)
                    .localize(titleKey, for: user.language, on: container)
            }
            return try container.make(LeafRenderer.self)
                .render(templateName, templateContext, userInfo: [ "language": user.language ?? ""])
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
