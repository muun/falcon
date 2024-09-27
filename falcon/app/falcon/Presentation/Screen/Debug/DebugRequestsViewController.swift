//
//  DebugRequestsViewController.swift
//  Muun
//
//  Created by Lucas Serruya on 21/09/2023.
//  Copyright © 2023 muun. All rights reserved.
//

import UIKit
import core

class DebugRequestsViewController: MUViewController {
    private lazy var presenter = instancePresenter(DebugRequestsPresenter.init, delegate: self)
    private lazy var tableView = DebugTableView(presenter: presenter,
                                                tableViewDelegate: self,
                                                presentingViewController: self)

    override var screenLoggingName: String {
        return "debug_requests"
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

extension DebugRequestsViewController: DebugRequestsPresenterDelegate {

}

extension DebugRequestsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let request = presenter.getRequestFor(cell: indexPath.row)
        let requestDetail = DebugRequestDetail(request: request)
        navigationController?.pushViewController(requestDetail, animated: true)
    }
}
