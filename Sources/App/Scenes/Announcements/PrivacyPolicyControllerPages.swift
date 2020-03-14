import Domain

import Vapor

extension Page {

    static func privacyPolicy(with result: PresentPublicly.Result) throws -> Self {
        return .init(
            localizedTemplateName: "Public/PrivacyPolicy",
            context: PrivacyPolicyPageContext(for: result.user)
        )
    }

}
