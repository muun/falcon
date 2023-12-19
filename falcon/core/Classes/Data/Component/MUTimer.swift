//
//  MUTimer.swift
//  core-all
//
//  Created by Lucas Serruya on 23/10/2023.
//

import Foundation

/// Testeable timer
public class MUTimer {
    private var timer: Timer?

    public init() {}

    var timeInterval: TimeInterval {
        return timer?.timeInterval ?? -1
    }

    func stop() {
        DispatchQueue.main.async {
            self.timer?.invalidate()
            self.timer = nil
        }
    }

    func start(timeInterval: TimeInterval,
               target: Any,
               selector: Selector,
               repeats: Bool) {
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: timeInterval,
                                              target: target,
                                              selector: selector,
                                              userInfo: nil,
                                              repeats: repeats)
        }
    }
}
