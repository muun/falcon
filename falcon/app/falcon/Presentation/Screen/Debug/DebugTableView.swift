//
//  DebugTableView.swift
//  Muun
//
//  Created by Lucas Serruya on 23/07/2024.
//  Copyright © 2024 muun. All rights reserved.
//

import UIKit

class DebugTableView: UIView {
    private let closeButton = UIButton()
    private let tableView = UITableView()
    private var presenter: DebugListPresenter
    private let presentingViewController: UIViewController
    private var tableViewDelegate: UITableViewDelegate

    init(presenter: DebugListPresenter,
         tableViewDelegate: UITableViewDelegate,
         presentingViewController: UIViewController) {
        self.presenter = presenter
        self.tableViewDelegate = tableViewDelegate
        self.presentingViewController = presentingViewController
        super.init(frame: CGRect())
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUp() {
        configureCloseButton()
        setUpTableView()
    }

    private func setUpTableView() {
        tableView.delegate = tableViewDelegate
        tableView.dataSource = self
        tableView.tableFooterView = UIView()

        tableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)
        tableView.fitTo(parent: self, replacingTop: closeButton.bottomAnchor)
        tableView.reloadData()
    }

    private func configureCloseButton() {
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(.black, for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        addSubview(closeButton)
        closeButton.leadingAnchor.constraint(equalTo: leadingAnchor,
                                             constant: 16).isActive = true
        closeButton.topAnchor.constraint(equalTo: topAnchor,
                                         constant: 16).isActive = true
    }

    @objc func closeButtonTapped() {
        presentingViewController.navigationController?.popViewController(animated: true)
    }
}

extension DebugTableView: UITableViewDataSource {
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
        title.numberOfLines = 0
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
