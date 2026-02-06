//
//  DisableFeatureFlagsViewController.swift
//  falcon
//
//  Created by Daniel Mankowski on 05/11/2025.
//  Copyright © 2025 muun. All rights reserved.
//

import UIKit

final class DisableFeatureFlagsViewController: MUViewController {

    // MARK: - Properties
    private let contentView = UIView()
    private let tableView = UITableView()

    private lazy var presenter = instancePresenter(
        DisableFeatureFlagsPresenter.init,
        delegate: self
    )

    override var screenLoggingName: String {
        return "disable_feature_flag"
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.setUp()
        configureViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        presenter.setUp()
        tableView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        presenter.tearDown()
    }

    // MARK: - Private Methods
    private func configureViews() {
        view.backgroundColor = Asset.Colors.background.color
        title = L10n.DisableFeatureFlagsViewController.title

        configureContentView()
        configureTableView()
    }

    private func configureContentView() {
        view.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func configureTableView() {
        tableView.register(
            DisableFlagTableViewCell.self,
            forCellReuseIdentifier: DisableFlagTableViewCell.reuseIdentifier
        )
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.dataSource = self

        contentView.addSubview(tableView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: tableView.topAnchor),
            contentView.leftAnchor.constraint(equalTo: tableView.leftAnchor),
            contentView.rightAnchor.constraint(equalTo: tableView.rightAnchor),
            contentView.bottomAnchor.constraint(equalTo: tableView.bottomAnchor)
        ])
    }
}

extension DisableFeatureFlagsViewController: DisableFeatureFlagsPresenterDelegate {}

extension DisableFeatureFlagsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let flag = presenter.flag(for: indexPath)
        let isFlagOn = presenter.isOn(flag: flag)
        let cell = tableView.dequeue(type: DisableFlagTableViewCell.self, indexPath: indexPath)
        cell.setUp(flag: flag, isOn: isFlagOn)
        cell.delegate = self
        return cell
    }
}

extension DisableFeatureFlagsViewController: DisableFlagTableViewCellDelegate {
    func disableFlagToggleValueChanged(flag: FeatureFlags, isOn: Bool) {
        presenter.setFlagDisabled(flag, isDisabled: !isOn)
    }
}
