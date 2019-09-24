//
//  NotificationHandler.swift
//  falcon
//
//  Created by Juan Pablo Civile on 11/01/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import RxSwift

enum NotificationOrigin {
    case houston
    case apollo
    case satellite
}

protocol NotificationHandler {
    var permission: SessionStatus? { get }
    var origin: NotificationOrigin? { get }

    func process() -> Completable
}

struct CallbackNotificationHandler: NotificationHandler {

    let permission: SessionStatus?
    let origin: NotificationOrigin?
    let processor: () -> Completable

    init(_ permission: SessionStatus? = nil,
         _ origin: NotificationOrigin? = nil,
         processor: @escaping () -> Completable) {

        self.permission = permission
        self.origin = origin
        self.processor = processor
    }

    func process() -> Completable {
        return processor()
    }
}

struct FutureCompatNotificationHandler: NotificationHandler {

    let permission: SessionStatus? = nil
    let origin: NotificationOrigin? = nil

    func process() -> Completable {
        return Completable.empty()
    }
}
