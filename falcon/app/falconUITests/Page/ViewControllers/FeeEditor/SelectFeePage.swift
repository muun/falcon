//
//  SelectFeePage.swift
//  falconUITests
//
//  Created by Manu Herrera on 27/06/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation

final class SelectFeePage: UIElementPage<UIElements.Pages.SelectFeePage> {

    private let button = ButtonViewPage(Root.button)
    private lazy var tableView = table(Root.tableView)

    init() {
        super.init(root: Root.root)
    }

    func selectFee(index: Int) {
        tableView.cells.element(boundBy: index).tap()
        button.mainButtonTap()
    }

    func tapEnterFeeManually() -> ManuallyEnterFeePage {
        tableView.cells.element(boundBy: 4).tap()
        return ManuallyEnterFeePage()
    }

}
