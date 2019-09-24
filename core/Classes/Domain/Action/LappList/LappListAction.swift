//
//  LappListAction.swift
//  falcon
//
//  Created by Manu Herrera on 25/04/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit

public class LappListAction: AsyncAction<[Lapp]> {

    private let muunWebService: MuunWebService

    public init(muunWebService: MuunWebService) {
        self.muunWebService = muunWebService

        super.init(name: "LappListAction")
    }

    public func run() {
        runSingle(muunWebService.fetchLappList()
            .map({ lapp in
                return lapp
            })
        )
    }

}
