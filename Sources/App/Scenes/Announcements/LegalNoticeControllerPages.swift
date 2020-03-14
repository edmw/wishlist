import Domain

import Vapor

extension Page {

    static func legalNotice(with result: PresentPublicly.Result) throws -> Self {
        return .init(
            templateName: "Public/LegalNotice",
            context: LegalNoticePageContext(for: result.user)
        )
    }

}
