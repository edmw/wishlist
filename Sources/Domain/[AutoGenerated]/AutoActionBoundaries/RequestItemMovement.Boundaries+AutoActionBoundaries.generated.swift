// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import DomainModel

import NIO

// MARK: RequestItemMovement.Boundaries

extension RequestItemMovement.Boundaries {

    public static func boundaries(
        worker: EventLoop
    ) -> Self {
        return Self(
            worker: worker
        )
    }

}
