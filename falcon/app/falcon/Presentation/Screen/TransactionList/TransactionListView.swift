//
//  TransactionListView.swift
//  falcon
//
//  Created by Manu Herrera on 04/12/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit
import core

protocol TransactionListViewDelegate: class {
    func didTapLoadWallet()
    func didTapOperation(_ operation: core.Operation)
}

final class TransactionListView: UIView {

    private var emptyStateView: TransactionListEmptyView!
    private var tableView: UITableView! = UITableView()

    private var operations: LazyLoadedList<core.Operation> = LazyLoadedList()

    private weak var delegate: TransactionListViewDelegate?

    private let serialQueue = DispatchQueue(label: "pagination")

    init(delegate: TransactionListViewDelegate?) {
        self.delegate = delegate
        super.init(frame: .zero)

        setUpView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setUpView() {
        setUpEmptyState()
        setUpTableView()

        makeViewTestable()
    }

    fileprivate func setUpEmptyState() {
        emptyStateView = TransactionListEmptyView(delegate: self)

        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(emptyStateView)
        NSLayoutConstraint.activate([
            emptyStateView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        emptyStateView.isHidden = true
    }

    fileprivate func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(type: OperationTableViewCell.self)
        tableView.tableFooterView = UIView()

        tableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        tableView.isHidden = true
    }

    fileprivate func decideView() {
        if operations.isEmpty {
            showEmptyState()
        } else {
            showOperations()
        }
    }

    fileprivate func showEmptyState() {
        emptyStateView.isHidden = false
        tableView.isHidden = true
    }

    fileprivate func showOperations() {
        emptyStateView.isHidden = true
        tableView.reloadData()
        tableView.isHidden = false
    }

    fileprivate func getOperationAt(_ index: Int) -> core.Operation? {
        guard index < operations.count else {
            return nil
        }
        return operations[index]
    }

    // MARK: - View Controller actions -

    func updateOperations(_ ops: LazyLoadedList<core.Operation>) {
        self.operations = ops
        decideView()
    }

    private func loadMore() {
        let operations = self.operations

        serialQueue.async {
            let changed = operations.loadMore(count: 50)
            if changed {
                DispatchQueue.main.async {
                    // reload data only if operations have not changed
                    if operations === self.operations {
                        self.decideView()
                    }
                }
            }
        }
    }

}

extension TransactionListView: TransactionListEmptyViewDelegate {

    func didTapOnLoadWallet() {
        delegate?.didTapLoadWallet()
    }

}

extension TransactionListView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let op = getOperationAt(indexPath.row)
        if let op = op {
            delegate?.didTapOperation(op)
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if operations.count - indexPath.row < 10 {
            loadMore()
        }
    }

}

extension TransactionListView: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return operations.total
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(type: OperationTableViewCell.self, indexPath: indexPath)
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = .zero
        cell.layoutMargins = .zero

        if let op = getOperationAt(indexPath.row) {
            cell.setUp(op)
        }

        return cell
    }

}

extension TransactionListView: UITestablePage {

    typealias UIElementType = UIElements.Pages.TransactionListPage

    func makeViewTestable() {
        makeViewTestable(tableView, using: .tableView)
    }

}
