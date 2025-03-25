//
//  TransactionListViewController.swift
//  falcon
//
//  Created by Manu Herrera on 04/12/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

protocol TransactionListViewControllerDelegate: AnyObject {
    func didTapLoadWallet()
}

class TransactionListViewController: MUViewController {

    fileprivate lazy var presenter = instancePresenter(TransactionListPresenter.init,
                                                       delegate: self)

    private weak var delegate: TransactionListViewControllerDelegate?
    private var txListView: TransactionListView!

    override var screenLoggingName: String {
        return "transactions"
    }

    init(delegate: TransactionListViewControllerDelegate?) {
        self.delegate = delegate

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        preconditionFailure()
    }

    override func loadView() {
        super.loadView()

        txListView = TransactionListView(delegate: self)
        self.view = txListView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        makeViewTestable()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        additionalSafeAreaInsets = UIEdgeInsets.zero
        setUpNavigation()

        presenter.setUp()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        presenter.tearDown()
    }

    fileprivate func setUpNavigation() {
        navigationController!.setNavigationBarHidden(false, animated: true)
        navigationController!.showSeparator()

        title = L10n.TransactionListViewController.vcTitle
    }

}

extension TransactionListViewController: TransactionListPresenterDelegate {

    func onOperationsChange(_ ops: LazyLoadedList<Operation>) {
        txListView.updateOperations(ops)
    }

}

extension TransactionListViewController: TransactionListViewDelegate {

    func didTapLoadWallet() {
        navigationController?.dismiss(animated: true, completion: {
            self.delegate?.didTapLoadWallet()
        })
    }

    func didTapOperation(_ operation: Operation) {
        navigationController?.pushViewController(
            DetailViewController(operation: operation),
            animated: true
        )
    }

}

extension TransactionListViewController: UITestablePage {

    typealias UIElementType = UIElements.Pages.TransactionListPage

    func makeViewTestable() {
        makeViewTestable(view, using: .root)
    }

}
