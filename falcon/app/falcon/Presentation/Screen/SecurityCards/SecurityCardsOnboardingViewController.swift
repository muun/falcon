//
//  SecurityCardsOnboardingViewController.swift
//  falcon
//
//  Created by Federico Jordán on 10/04/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import UIKit

final class SecurityCardsOnboardingViewController: MUViewController {

    private enum Constants {
        static let pageControlBottomInset: CGFloat = 80
    }

    private let pageVC = UIPageViewController(
        transitionStyle: .scroll, navigationOrientation: .horizontal
    )
    private let pageControl = UIPageControl()
    private let buttonView = ButtonView()
    private let hintLabel = UILabel()

    // swiftlint:disable:next force_error_handling — false positive on optional type
    private var selectedCountry: Country?
    private var hasRevealedFinishButton = false
    private var currentIndex = 0
    private lazy var countrySlideVC = CountrySlideViewController(delegate: self)
    private lazy var presenter = instancePresenter(
        SecurityCardsOnboardingPresenter.init,
        delegate: self
    )

    private lazy var pages: [UIViewController] = {
        let slidePages = SecurityCardsSlidesConfiguration.slides.map { slide -> UIViewController in
            let vc = UIViewController()
            let slideView = SlideView()
            slideView.setUp(
                image: slide.image.image,
                title: slide.title,
                description: slide.description.attributedForDescription(alignment: .center)
            )
            slideView.translatesAutoresizingMaskIntoConstraints = false
            vc.view.addSubview(slideView)
            NSLayoutConstraint.activate([
                slideView.topAnchor.constraint(equalTo: vc.view.topAnchor),
                slideView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
                slideView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
                slideView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor)
            ])
            return vc
        }

        return slidePages + [countrySlideVC]
    }()

    override var screenLoggingName: String {
        "security_cards_onboarding"
    }

    override func customLoggingParameters() -> [String: Any]? {
        ["step": currentIndex]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.SecurityCardsOnboarding.title
        setupPageViewController()
        setupPageControl()
        setupHintLabel()
        setupButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: Constant.Images.back,
            style: .plain,
            target: self,
            action: #selector(didTapBack)
        )
        setupTransparentNavBar()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        restoreNavBar()
    }

    // MARK: - Setup

    private func setupPageViewController() {
        addChild(pageVC)
        view.addSubview(pageVC.view)
        pageVC.view.translatesAutoresizingMaskIntoConstraints = false
        pageVC.didMove(toParent: self)
        pageVC.dataSource = self
        pageVC.delegate = self

        NSLayoutConstraint.activate([
            pageVC.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        pageVC.setViewControllers([pages[0]], direction: .forward, animated: false)
    }

    private func setupPageControl() {
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = MuunTheme.Color.Border.primary
        pageControl.currentPageIndicatorTintColor = MuunTheme.Color.Text.action
        pageControl.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(pageControl)

        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -Constants.pageControlBottomInset
            )
        ])
    }

    private func setupHintLabel() {
        hintLabel.textColor = MuunTheme.Color.Text.bodySecondary
        hintLabel.font = Constant.Fonts.italic(size: .desc)
        hintLabel.text = L10n.SlidesViewController.swipe
        hintLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(hintLabel)

        NSLayoutConstraint.activate([
            hintLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hintLabel.bottomAnchor.constraint(
                equalTo: pageControl.topAnchor,
                constant: -MuunTheme.Spacing.xs
            )
        ])
    }

    private func setupButton() {
        buttonView.buttonText = L10n.CountryOnboardingViewController.startExploring
        buttonView.delegate = self
        buttonView.isEnabled = false
        buttonView.alpha = 0
        buttonView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(buttonView)

        NSLayoutConstraint.activate([
            buttonView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: MuunTheme.Spacing.xl
            ),
            buttonView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -MuunTheme.Spacing.xl
            ),
            buttonView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -MuunTheme.Spacing.xl
            )
        ])
    }

    // MARK: - Actions

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Page Updates

    private func updateForPage(_ index: Int) {
        currentIndex = index
        pageControl.currentPage = index

        let isLastSlide = index == pages.count - 1

        if isLastSlide {
            hintLabel.isHidden = true
            if !hasRevealedFinishButton {
                hasRevealedFinishButton = true
                buttonView.animate(direction: .bottomToTop, duration: .short)
            }
        } else {
            hintLabel.isHidden = false
        }

        logScreen()
    }
}

// MARK: - UIPageViewControllerDataSource

extension SecurityCardsOnboardingViewController: UIPageViewControllerDataSource {

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let idx = pages.firstIndex(of: viewController), idx > 0 else { return nil }
        return pages[idx - 1]
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let idx = pages.firstIndex(of: viewController),
              idx + 1 < pages.count else { return nil }
        return pages[idx + 1]
    }
}

// MARK: - UIPageViewControllerDelegate

extension SecurityCardsOnboardingViewController: UIPageViewControllerDelegate {

    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard completed,
              let current = pageViewController.viewControllers?.first,
              let idx = pages.firstIndex(of: current) else { return }
        updateForPage(idx)
    }
}

// MARK: - ButtonViewDelegate

extension SecurityCardsOnboardingViewController: ButtonViewDelegate {

    func button(didPress button: ButtonView) {
        guard let selectedCountry else { return }
        presenter.set(selectedCountry: selectedCountry)
        navigationController?.pushViewController(
            MarketplaceViewController(),
            animated: true
        )
    }
}

// MARK: - CountrySelectorViewControllerDelegate

extension SecurityCardsOnboardingViewController: CountrySelectorViewControllerDelegate {

    func countrySelectorDidSelect(country: Country) {
        selectedCountry = country
        buttonView.isEnabled = true
        countrySlideVC.updateCountry(country)
    }
}

// MARK: - CountrySlideViewControllerDelegate

extension SecurityCardsOnboardingViewController: CountrySlideViewControllerDelegate {

    func countrySlideDidTapSelectCountry() {
        // swiftlint:disable:next force_error_handling — false positive on optional chaining
        let code = selectedCountry?.code ?? ""
        let vc = CountrySelectorViewController(selectedCountryCode: code, delegate: self)
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
}
