//
//  MarketplaceViewController.swift
//  falcon
//
//  Created by Federico Jordán on 23/01/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import UIKit

final class MarketplaceViewController: MUViewController {
    private enum Constants {
        static let tabsViewHeight = MuunTheme.Legacy.s52
    }

    private let titleLabel = UILabel()
    private let providerTabsView = SecurityCardProvidersTabsView()
    private var selectedProviderIndex = 0
    private lazy var presenter = instancePresenter(MarketplacePresenter.init, delegate: self)
    private var cachedProviders: [SecurityCardProvider] = []
    private var pages: [UIViewController] = []
    private lazy var pageVC: UIPageViewController = {
        let vc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        vc.dataSource = self
        vc.delegate = self
        return vc
    }()

    private var currentIndex: Int = 0

    override var screenLoggingName: String {
        "security_cards_marketplace"
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        presenter.loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        additionalSafeAreaInsets = .zero
        presenter.setUp()
        setupTransparentNavBar()
        // Refresh in case the country changed downstream (e.g. in the shipping screen).
        navigationItem.rightBarButtonItem?.title = presenter.selectedCountryFlag
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.tearDown()
        restoreNavBar()
    }

    // Interface

    private func setupView() {
        setupCountryBarButton()
        setupTitleView()
        setupProviderTabs()
        setupPages()
    }

    private func setupTitleView() {
        titleLabel.text = L10n.MarketplaceViewController.title
        titleLabel.font = MuunTheme.Font.Heading.h1
        titleLabel.textAlignment = .center
        navigationItem.titleView = titleLabel
    }

    private func setupPages() {
        addChild(pageVC)
        let pageContainer = UIView()
        pageContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageContainer)
        pageContainer.addSubview(pageVC.view)
        pageVC.view.translatesAutoresizingMaskIntoConstraints = false

        pageVC.didMove(toParent: self)

        NSLayoutConstraint.activate([
            pageContainer.topAnchor.constraint(
                equalTo: providerTabsView.bottomAnchor,
                constant: MuunTheme.Spacing.sm
            ),
            pageContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            pageVC.view.topAnchor.constraint(equalTo: pageContainer.topAnchor),
            pageVC.view.leadingAnchor.constraint(equalTo: pageContainer.leadingAnchor),
            pageVC.view.trailingAnchor.constraint(equalTo: pageContainer.trailingAnchor),
            pageVC.view.bottomAnchor.constraint(equalTo: pageContainer.bottomAnchor)
        ])
    }

    private func setupProviderTabs() {
        view.addSubview(providerTabsView)
        providerTabsView.translatesAutoresizingMaskIntoConstraints = false
        providerTabsView.delegate = self

        NSLayoutConstraint.activate([
            providerTabsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            providerTabsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            providerTabsView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: MuunTheme.Spacing.sm
            ),
            providerTabsView.heightAnchor.constraint(
                equalToConstant: Constants.tabsViewHeight
            )
        ])
    }

    private func setupCountryBarButton() {
        let countryButtonItem = UIBarButtonItem(
            title: presenter.selectedCountryFlag,
            style: .plain,
            target: self,
            action: #selector(MarketplaceViewController.didTapCountry)
        )
        countryButtonItem.accessibilityIdentifier = "Select Country"
        navigationItem.rightBarButtonItem = countryButtonItem
    }

    // Actions

    @objc
    private func didTapCountry() {
        let vc = CountrySelectorViewController(
            selectedCountryCode: presenter.selectedCountryCode,
            delegate: self
        )
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
}

// MARK: - SecurityCardsProviderCarouselViewControllerDelegate

extension MarketplaceViewController: SecurityCardsProviderCarouselViewControllerDelegate {
    func carouselDidSelectCard(
        provider: SecurityCardProvider,
        card: SecurityCard,
        fromView: UIView,
        fromPriceFooter: UIView
    ) {
        let fromFrame = fromView.convert(fromView.bounds, to: nil)
        let priceFooterFrame = fromPriceFooter.convert(fromPriceFooter.bounds, to: nil)
        let priceFooterSnapshot = fromPriceFooter.snapshotView(afterScreenUpdates: false)
        let vc = BuyDetailsViewController(
            provider: provider,
            card: card,
            initialCardFrame: fromFrame,
            initialPriceFooterSnapshot: priceFooterSnapshot,
            initialPriceFooterFrame: priceFooterFrame
        )
        // Push without the slide animation so BuyDetails can drive its own hero
        // entrance (card flies from the tapped cell to its final position, the
        // marketplace price footer slides down off-screen, and the rest of the
        // content fades in).
        navigationController?.pushViewController(vc, animated: false)
    }
}

// MARK: - MarketplacePresenterDelegate

extension MarketplaceViewController: MarketplacePresenterDelegate {
    func update(providers: [SecurityCardProvider]) {
        cachedProviders = providers
        providerTabsView.configure(
            securityCardProviders: providers,
            selectedIndex: selectedProviderIndex
        )

        pages = providers.map {
            let carousel = SecurityCardsProviderCarouselViewController(
                provider: $0,
                priceFormatter: self.presenter
            )
            carousel.delegate = self
            return carousel
        }
        guard let first = pages.first else { return }
        pageVC.setViewControllers([first], direction: .forward, animated: false)
        currentIndex = 0
    }
}

// MARK: - SecurityCardProvidersTabsViewDelegate

extension MarketplaceViewController: SecurityCardProvidersTabsViewDelegate {
    func didSelectProvider(at index: Int) {
        providerTabsView.setSelectedIndex(index, animated: true)
        selectedProviderIndex = index

        guard index < pages.count else { return }
        let direction: UIPageViewController
            .NavigationDirection = index >= currentIndex ? .forward : .reverse
        pageVC.setViewControllers([pages[index]], direction: direction, animated: true)
        currentIndex = index
    }
}

// MARK: - CountrySelectorViewControllerDelegate

extension MarketplaceViewController: CountrySelectorViewControllerDelegate {
    func countrySelectorDidSelect(country: Country) {
        presenter.set(selectedCountry: country)
        navigationItem.rightBarButtonItem?.title = presenter.selectedCountryFlag
    }
}

// MARK: - UIPageViewController DataSource/Delegate

extension MarketplaceViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(
        _: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let idx = pages.firstIndex(of: viewController), idx - 1 >= 0 else { return nil }
        return pages[idx - 1]
    }

    func pageViewController(
        _: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let idx = pages.firstIndex(of: viewController),
              idx + 1 < pages.count else { return nil }
        return pages[idx + 1]
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating _: Bool,
        previousViewControllers _: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard completed,
              let current = pageViewController.viewControllers?.first,
              let idx = pages.firstIndex(of: current) else { return }
        currentIndex = idx
        selectedProviderIndex = currentIndex
        providerTabsView.setSelectedIndex(currentIndex, animated: true)
    }
}

