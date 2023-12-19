//
//  DebugMenuViewController.swift
//  Muun
//
//  Created by Lucas Serruya on 16/08/2023.
//  Copyright © 2023 muun. All rights reserved.
//

import UIKit

class DebugMenuViewController: MUViewController {
    private lazy var presenter = instancePresenter(DebugMenuPresenter.init, delegate: self)
    private let closeButton = UIButton()
    private var debugModeDisplayer: DebugModeDisplayer!
    private let tableView = UITableView()

    override var screenLoggingName: String {
        return "debug_menu"
    }

    init(debugModeDisplayer: DebugModeDisplayer) {
        self.debugModeDisplayer = debugModeDisplayer
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

extension DebugMenuViewController: DebugMenuPresenterDelegate {
    func askUserForText(message: String, completion: @escaping (String) -> Void) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: message,
                                                    message: nil,
                                                    preferredStyle: .alert)
            alertController.addTextField()

            let textFieldAction = UIAlertAction(title: "Accept",
                                                style: .default) { [weak alertController] _ in
                let loadedValue = alertController!.textFields![0]
                completion(loadedValue.text!)
            }

            alertController.addAction(textFieldAction)

            self.present(alertController, animated: true)
        }
    }

    func showRequests() {
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(DebugRequestsViewController(),
                                                          animated: true)
        }
    }
}

private extension DebugMenuViewController {
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
        debugModeDisplayer.onCloseDebugMenuTapped()
    }
}

extension DebugMenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.onExecutableSelected(groupIndex: indexPath.section,
                                       executableIndex: indexPath.row)
    }
}

extension DebugMenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfExecutablesIn(groupIndex: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let cellTitle = presenter.titleFor(groupIndex: indexPath.section,
                                           executableIndex: indexPath.row)
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

    func numberOfSections(in tableView: UITableView) -> Int {
        presenter.numberOfGroups()
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        presenter.titleFor(groupIndex: section)
    }
}

