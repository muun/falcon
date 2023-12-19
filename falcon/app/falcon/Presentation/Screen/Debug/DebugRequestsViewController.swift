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
    private let closeButton = UIButton()
    private let tableView = UITableView()

    override var screenLoggingName: String {
        return "requests_history"
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

        configureCloseButton()
        setUpTableView()
    }
}

extension DebugRequestsViewController: DebugRequestsPresenterDelegate {

}

private extension DebugRequestsViewController {
    func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()

        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: closeButton.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        tableView.reloadData()
    }

    func configureCloseButton() {
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(.black, for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        view.addSubview(closeButton)
        closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                             constant: 16).isActive = true
        closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                         constant: 16).isActive = true
    }

    @objc func closeButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension DebugRequestsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let request = presenter.getRequestFor(cell: indexPath.row)
        let requestDetail = DebugRequestDetail(request: request)
        navigationController?.pushViewController(requestDetail, animated: true)
    }
}

extension DebugRequestsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfRequests()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let cellTitle = presenter.titleFor(cell: indexPath.row)
        let title = UILabel()
        title.text = cellTitle
        title.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(title)
        NSLayoutConstraint.activate([
            cell.contentView.leadingAnchor.constraint(equalTo: title.leadingAnchor, constant: 16),
            cell.contentView.centerYAnchor.constraint(equalTo: title.centerYAnchor),
            title.heightAnchor.constraint(equalTo: cell.contentView.heightAnchor, multiplier: 0.8)
        ])

        return cell
    }
}
