// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation
import NIO

// MARK: SendInvitationEmail.Boundaries

extension SendInvitationEmail.Boundaries {

    public static func boundaries(
        worker: EventLoop,
        emailSending emailsending: EmailSendingProvider
    ) -> Self {
        return Self(
            worker: worker,
            emailSending: emailsending
        )
    }

}
