//
//  CurrencyPickerPage.swift
//  falconUITests
//
//  Created by Manu Herrera on 29/07/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation

final class CurrencyPickerPage: UIElementPage<UIElements.Pages.CurrencyPicker> {

    private lazy var tableView = self.table(.tableView)

    init() {
        super.init(root: Root.root)
    }

    func selectCurrency(index: Int) -> NewOpAmountPage {
        tableView.cells.element(boundBy: index).tap()
        return NewOpAmountPage()
    }
}
