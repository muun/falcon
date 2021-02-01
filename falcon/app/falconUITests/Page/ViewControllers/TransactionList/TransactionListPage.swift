//
//  TransactionListPage.swift
//  falconUITests
//
//  Created by Federico Bond on 08/12/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import XCTest

final class TransactionListPage: UIElementPage<UIElements.Pages.TransactionListPage> {

    private lazy var tableView = table(.tableView)

    var operationCells: [OperationCellPage] {
        let elements = tableView.cells.allElementsBoundByIndex.filter {
            $0.identifier.contains(UIElements.Cells.OperationCellPage.root.rawValue)
        }
        return elements.map({ OperationCellPage(element: $0) })
    }

    init() {
        super.init(root: Root.root)
    }

    func assertOperationsCount(equalTo count: Int) {
        _ = tableView.waitForExistence(timeout: 4)
        XCTAssertEqual(operationCells.count, count)
    }

}
