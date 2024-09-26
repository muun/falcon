//
//  DebugAnalyticsViewController.swift
//  Muun
//
//  Created by Lucas Serruya on 23/07/2024.
//  Copyright © 2024 muun. All rights reserved.
//

import UIKit

class DebugAnalyticsViewController: MUViewController {
    private lazy var presenter = instancePresenter(DebugAnalyticsPresenter.init, delegate: self)
    private lazy var tableView = DebugTableView(presenter: presenter,
                                                tableViewDelegate: self,
                                                presentingViewController: self)

    override var screenLoggingName: String {
        return "debug_analytics"
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        view.backgroundColor = .systemGray
        navigationController?.isNavigationBarHidden = true
        view.addSubview(tableView)
        tableView.fitTo(parent: self.view, replacingTop: view.safeAreaLayoutGuide.topAnchor)
        tableView.setUp()
    }
}

extension DebugAnalyticsViewController: DebugAnalyticsPresenterDelegate, UITableViewDelegate {

}
