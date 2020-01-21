// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import DomainModel

import NIO

// MARK: CreateOrUpdateItem.Boundaries

extension CreateOrUpdateItem.Boundaries {

    public static func boundaries(
        worker: EventLoop,
        imageStore imagestore: ImageStoreProvider
    ) -> Self {
        return Self(
            worker: worker,
            imageStore: imagestore
        )
    }

}
