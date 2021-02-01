//
//  Optional+Extension.swift
//  falcon
//
//  Created by Manu Herrera on 07/08/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation

extension Optional {
    func orElse(_ f: @autoclosure () -> Wrapped?) -> Wrapped? {
        if self != nil {
            return self
        }
        return f()
    }
}
