//
//  RxSwift+Extension.swift
//  falcon
//
//  Created by Manu Herrera on 13/12/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import RxSwift

extension Observable {

    func first() -> Observable {
        return self.take(1)
    }

    func last() -> Observable {
        return self.takeLast(1)
    }

}
