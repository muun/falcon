//
//  HomeViewController.swift
//  falcon
//
//  Created by Manu Herrera on 05/12/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import UIKit
import core

class HomeViewController: MUViewController {

    fileprivate lazy var presenter = instancePresenter(HomePresenter.init, delegate: self)

    private var homeView: HomeView!
    private var companion: HomeCompanion = .none

    override var screenLoggingName: String {
        return "home"
    }

    override func customLoggingParameters() -> [String: Any]? {
        return ["type": presenter.logType()]
    }

    override func loadView() {
        super.loadView()

        homeView = HomeView(delegate: self)
        self.view = homeView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Asset.Colors.cellBackground.color

        makeViewTestable()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        additionalSafeAreaInsets = UIEdgeInsets.zero
        setUpNavigation()
        populateView()

        presenter.setUp()

        if presenter.shouldDisplayTransactionListTooltip() {
            homeView.displayTooltip()
        } else {
            homeView.hideTooltip()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        presenter.tearDown()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    private func populateView() {
        populateBalanceView()
        homeView.updateBalanceAndChevron(state: presenter.getOperationsState())
    }

    fileprivate func setUpNavigation() {
        navigationController!.setNavigationBarHidden(false, animated: true)
        navigationController!.hideSeparator()

        setUpRightButtonItems()
        setUpLeftButtonItems()
    }

    fileprivate func setUpRightButtonItems() {

        let supportButton = UIBarButtonItem(
            image: Asset.Assets.feedback.image,
            style: .plain,
            target: self,
            action: .supportTouched
        )

        self.navigationItem.rightBarButtonItems = [supportButton]
    }

    fileprivate func setUpLeftButtonItems() {
        let label = UILabel()
        label.text = "Muun"
        label.textAlignment = .left
        label.font = Constant.Fonts.system(size: .homeCurrency, weight: .medium)
        label.textColor = Asset.Colors.title.color

        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: label)]
    }

    @objc fileprivate func supportTouched() {
        let navController = UINavigationController()

        if !presenter.hasEmailAndPassword() {
            navController.viewControllers = [SupportViewController(type: .help)]
            present(navController, animated: true)
        } else {
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

            actionSheet.addAction(UIAlertAction(title: L10n.HomeViewController.s1, style: .default, handler: { _ in

                navController.viewControllers = [SupportViewController(type: .help)]
                self.present(navController, animated: true)
            }))
            actionSheet.addAction(UIAlertAction(title: L10n.HomeViewController.s2, style: .default, handler: { _ in
                navController.viewControllers = [SupportViewController(type: .feedback)]
                self.present(navController, animated: true)
            }))

            actionSheet.addAction(UIAlertAction(title: L10n.HomeViewController.s3, style: .cancel, handler: { _ in
                actionSheet.dismiss(animated: true)
            }))

            present(actionSheet, animated: true)
        }
    }

    private func populateBalanceView() {
        homeView.setUp(
            btcBalance: presenter.getBTCBalance(),
            primaryBalance: presenter.getPrimaryBalance(),
            isBalanceHidden: presenter.isBalanceHidden()
        )
    }

}

extension HomeViewController: HomePresenterDelegate {

    func showWelcome() {
        _ = show(popUp: WelcomePopUpView(), duration: nil)
    }

    func showTaprootActivated() {
        _ = show(popUp: TaprootActivatedPopup(delegate: self), duration: nil)
    }

    func didReceiveNewOperation(amount: MonetaryAmount, direction: OperationDirection) {
        homeView.displayOpsBadge(bitcoinAmount: amount, direction: direction)
    }

    func onBalanceVisibilityChange(_ isHidden: Bool) {
        homeView.setBalanceHidden(isHidden)
    }

    func onOperationsChange() {
        populateView()
    }

    func onBalanceChange(_ balance: MonetaryAmount) {
        populateBalanceView()
    }

    func onCompanionChange(_ companion: HomeCompanion) {

        self.companion = companion
        switch companion {
        case .backUp:
            homeView.show(actionCard: .homeBackUp())
        case .activateTaproot:
            homeView.show(actionCard: .activateTaproot())
        case .preactiveTaproot:
            homeView.show(actionCard: .activateTaproot())
        case .blockClock(let blocksLeft):
            homeView.show(blocksLeft: blocksLeft)
        case .highFeesHomeBanner:
            homeView.show(actionCard: .highFeesHomeBanner())
        case .none:
            homeView.hideCompanion()
        }
    }

}

extension HomeViewController: HomeViewDelegate {

    func sendButtonTap() {
        navigationController!.pushViewController(ScanQRViewController(), animated: true)
    }

    func receiveButtonTap() {
        navigationController!.pushViewController(ReceiveViewController(origin: .receiveButton), animated: true)
    }

    func chevronTap() {
        let txListVc = TransactionListViewController(delegate: self)
        let txListNavBar = UINavigationController(rootViewController: txListVc)
        txListNavBar.modalPresentationStyle = .fullScreen
        navigationController!.present(txListNavBar, animated: true)
    }

    func companionTap() {
        switch companion {
        case .backUp:
            SecurityCenterViewController.origin = .emptyAnonUser
            tabBarController!.selectedIndex = 1

        case .activateTaproot:
            pushTo(SlidesViewController(
                configuration: .taprootActivation(successFeedback: FeedbackInfo.taprootActive)
            ))

        case .highFeesHomeBanner:
            break

        case .preactiveTaproot(let blocksLeft):
            let feedbackInfo = FeedbackInfo.taprootPreactived(blocksLeft: blocksLeft)
            pushTo(SlidesViewController(
                configuration: .taprootActivation(successFeedback: feedbackInfo)
            ))

        case .blockClock(let blocksLeft):
            navigationController!.pushViewController(
                FeedbackViewController(feedback: FeedbackInfo.taprootPreactivationCountdown(blocksLeft: blocksLeft)),
                animated: true
            )

        case .none:
            // Do nothing
            ()
        }
    }

    func balanceTap() {
        presenter.toggleBalanceVisibility()
    }

    func didShowTransactionListTooltip() {
        presenter.setTooltipSeen()
    }

}

extension HomeViewController: TransactionListViewControllerDelegate {

    func didTapLoadWallet() {
        receiveButtonTap()
    }

}

extension HomeViewController: TaprootActivatedPopupDelegate {

    func dismiss(taprootActivated: TaprootActivatedPopup) {
        self.dismissPopUp()
    }
}

extension HomeViewController: UITestablePage {

    typealias UIElementType = UIElements.Pages.HomePage

    func makeViewTestable() {
        makeViewTestable(view, using: .root)
    }

}

fileprivate extension Selector {
    static let supportTouched = #selector(HomeViewController.supportTouched)
}
