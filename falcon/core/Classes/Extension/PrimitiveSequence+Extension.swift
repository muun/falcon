//
//  Completable+Extension.swift
//  core.root-all-notifications
//
//  Created by Juan Pablo Civile on 27/01/2021.
//

import RxSwift

extension PrimitiveSequence where Trait == CompletableTrait, Element == Never {

    public static func executing(action: @escaping () throws -> ()) -> Self {
        return Completable.deferred {
            try action()

            return Completable.empty()
        }
    }
}

extension PrimitiveSequence where Trait == SingleTrait {

    public static func from(producer: @escaping () throws -> Element) -> Self {
        return Single.deferred {
            return Single.just(try producer())
        }
    }
}
