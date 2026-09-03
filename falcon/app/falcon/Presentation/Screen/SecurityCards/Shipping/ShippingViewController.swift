//
//  ShippingViewController.swift
//  falcon
//
//  Created by Federico Jordán on 20/03/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import UIKit

final class ShippingViewController: MUViewController {

    private enum Constants {
        static let haloHeightPadding: CGFloat = 40
        static let ctaButtonHeight: CGFloat = 50
        static let ctaButtonCornerRadius: CGFloat = 8
        static let connectingMinDelay: TimeInterval = 0.8
        static let connectingMaxDelay: TimeInterval = 1.8
    }

    private var presenter: ShippingPresenter<ShippingViewController>!

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let haloView = SecurityCardGradientHaloView()
    private let subtitleLabel = UILabel()
    private let formView = ShippingFormView()
    private let ctaButton = UIButton(type: .system)
    private lazy var connectingOverlay = SecurityCardConnectingOverlayView()
    private var connectingDismissWorkItem: DispatchWorkItem?
    private var haloHeightConstraint: NSLayoutConstraint!
    private var contentMinHeightConstraint: NSLayoutConstraint!
    private let topFadeMask = ScrollViewTopFadeMask()

    private var hasShownConnecting = false
    private var hasSetupPill = false
    private weak var providerPill: SecurityCardProviderPillView?
    private let pillTapFeedback = UIImpactFeedbackGenerator(style: .medium)

    override var screenLoggingName: String { "security_cards_shipping" }

    init(provider: SecurityCardProvider) {
        super.init(nibName: nil, bundle: nil)
        presenter = ShippingPresenter(delegate: self, provider: provider)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        additionalSafeAreaInsets = .zero
        navigationController?.navigationBar.prefersLargeTitles = true
        presenter.setUp()
        setupTransparentNavBar()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.tearDown()
        restoreNavBar()
        connectingDismissWorkItem?.cancel()
        connectingDismissWorkItem = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = L10n.ShippingViewController.title
        navigationItem.largeTitleDisplayMode = .always
        setupHaloView()
        setupScrollView()
        setupHeader()
        setupForm()
        setupCTAButton()
        setupDismissKeyboardOnTap()
        registerKeyboardNotifications()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Layout

    private func setupHaloView() {
        haloView.translatesAutoresizingMaskIntoConstraints = false
        haloView.isUserInteractionEnabled = false
        view.addSubview(haloView)

        haloHeightConstraint = haloView.heightAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            haloView.topAnchor.constraint(equalTo: view.topAnchor),
            haloView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            haloView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            haloHeightConstraint
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        haloHeightConstraint.constant = view.bounds.width / 2 + Constants.haloHeightPadding
        topFadeMask.updateMask()
        updateContentMinHeight()
    }

    /// Auto Layout can't reference adjustedContentInset (nav bar / large title),
    /// so the visible-height correction is applied by hand on every layout pass.
    private func updateContentMinHeight() {
        let insets = scrollView.adjustedContentInset
        let constant = -(insets.top + insets.bottom)
        if contentMinHeightConstraint.constant != constant {
            contentMinHeightConstraint.constant = constant
        }
    }

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        // Lets short content pull the collapsed large title back open.
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        // The halo at subview index 0 breaks UIKit's scroll auto-tracking, so link it by hand.
        setContentScrollView(scrollView, for: .top)
        topFadeMask.attach(to: scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        // Fills the viewport on tall screens so the CTA anchors to the bottom;
        // taller-than-viewport content scrolls as usual. The constant discounts
        // the scroll insets and is kept in sync in updateContentMinHeight().
        contentMinHeightConstraint = contentView.heightAnchor.constraint(
            greaterThanOrEqualTo: scrollView.frameLayoutGuide.heightAnchor
        )

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor
                .constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor
                .constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor
                .constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            contentMinHeightConstraint
        ])
    }

    private func setupHeader() {
        subtitleLabel.font = MuunTheme.Font.Body.md
        subtitleLabel.textColor = MuunTheme.Color.Text.bodySecondary
        subtitleLabel.numberOfLines = 0
        subtitleLabel.text = L10n.ShippingViewController.subtitle
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            subtitleLabel.topAnchor.constraint(
                equalTo: contentView.safeAreaLayoutGuide.topAnchor,
                constant: MuunTheme.Spacing.sm
            ),
            subtitleLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: MuunTheme.Spacing.xl
            ),
            subtitleLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -MuunTheme.Spacing.xl
            )
        ])
    }

    private func setupForm() {
        formView.delegate = self
        formView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(formView)
        NSLayoutConstraint.activate([
            formView.topAnchor.constraint(
                equalTo: subtitleLabel.bottomAnchor,
                constant: MuunTheme.Spacing.xl3
            ),
            formView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: MuunTheme.Spacing.xl
            ),
            formView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -MuunTheme.Spacing.xl
            )
        ])
    }

    private func setupCTAButton() {
        ctaButton.titleLabel?.font = Constant.Fonts.system(
            size: .desc,
            weight: MuunAliases.FontWeight.textStrong
        )
        ctaButton.setTitle(L10n.ShippingViewController.cta, for: .normal)
        ctaButton.setTitleColor(MuunTheme.Color.Text.onActionPrimary, for: .normal)
        ctaButton.layer.cornerRadius = Constants.ctaButtonCornerRadius
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        ctaButton.addTarget(self, action: #selector(didTapCTA), for: .touchUpInside)
        contentView.addSubview(ctaButton)

        // The gap above the CTA absorbs any extra height when the content
        // stretches to fill the viewport, pushing the button down.
        let preferredTopSpacing = ctaButton.topAnchor.constraint(
            equalTo: formView.bottomAnchor,
            constant: MuunTheme.Spacing.xl3
        )
        preferredTopSpacing.priority = .defaultLow

        NSLayoutConstraint.activate([
            ctaButton.topAnchor.constraint(
                greaterThanOrEqualTo: formView.bottomAnchor,
                constant: MuunTheme.Spacing.xl3
            ),
            preferredTopSpacing,
            ctaButton.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: MuunTheme.Spacing.xl
            ),
            ctaButton.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -MuunTheme.Spacing.xl
            ),
            ctaButton.heightAnchor.constraint(equalToConstant: Constants.ctaButtonHeight),
            ctaButton.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -MuunTheme.Spacing.xl3
            )
        ])
    }

    private func setupRightPill(url: URL) {
        guard !hasSetupPill else { return }
        hasSetupPill = true
        let pill = SecurityCardProviderPillView(url: url)
        pill.delegate = self
        providerPill = pill
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: pill)
        pillTapFeedback.prepare()
    }

    private func showConnectingOverlay(providerName: String, color: UIColor) {
        guard !hasShownConnecting else { return }
        hasShownConnecting = true
        connectingOverlay.show(in: view, providerName: providerName, color: color)

        let delay = Double.random(in: Constants.connectingMinDelay...Constants.connectingMaxDelay)
        let workItem = DispatchWorkItem { [weak self] in
            self?.connectingOverlay.dismiss(completion: {})
        }
        connectingDismissWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
    }

    private func setupDismissKeyboardOnTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        // Let text field taps still hit the field so editing can move between rows.
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    // MARK: - Actions

    @objc private func didTapCTA() {
        presenter.submit(formView.formValues())
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Keyboard avoidance

    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func keyboardWillShow(_ notification: NSNotification) {
        guard let keyboardFrame = notification
            .userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification
              .userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }

        let inset = keyboardFrame.height - view.safeAreaInsets.bottom
        UIView.animate(withDuration: duration) {
            self.scrollView.contentInset.bottom = inset
            self.scrollView.verticalScrollIndicatorInsets.bottom = inset
        }
    }

    @objc private func keyboardWillHide(_ notification: NSNotification) {
        guard let duration = notification
            .userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }

        UIView.animate(withDuration: duration) {
            self.scrollView.contentInset.bottom = 0
            self.scrollView.verticalScrollIndicatorInsets.bottom = 0
        }
    }
}

// MARK: - ShippingPresenterDelegate

extension ShippingViewController: ShippingPresenterDelegate {

    func update(viewModel: ShippingViewModel) {
        haloView.configure(
            haloColor: viewModel.providerColor,
            backgroundColor: MuunTheme.Color.Surface.background
        )
        ctaButton.backgroundColor = viewModel.providerColor
        formView.configure(viewModel: ShippingFormViewModel(countryName: viewModel.country))
        if let url = viewModel.providerUrl {
            setupRightPill(url: url)
        }
        showConnectingOverlay(
            providerName: viewModel.providerName,
            color: viewModel.providerColor
        )
    }

    func displayFormErrors(_ errors: [ShippingFormField: String]) {
        formView.showErrors(errors)
    }

    func didValidateForm(provider: SecurityCardProvider, values: ShippingFormValues) {
        let orderSummary = OrderSummaryViewController(provider: provider, shippingValues: values)
        navigationController?.pushViewController(orderSummary, animated: true)
    }
}

// MARK: - SecurityCardProviderPillViewDelegate

extension ShippingViewController: SecurityCardProviderPillViewDelegate {

    func securityCardProviderPillViewDidTap(_ view: SecurityCardProviderPillView) {
        guard let providerURL = presenter.providerURL, let pill = providerPill else { return }
        pillTapFeedback.impactOccurred()
        pillTapFeedback.prepare()
        let modal = SecurityCardProviderInfoModal(
            providerURL: providerURL,
            sourceView: pill
        )
        present(modal, animated: true)
    }
}

// MARK: - ShippingFormViewDelegate

extension ShippingViewController: ShippingFormViewDelegate {

    func shippingFormViewDidTapCountry(_ view: ShippingFormView) {
        let vc = CountrySelectorViewController(
            selectedCountryCode: presenter.selectedCountryCode,
            delegate: self
        )
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
}

// MARK: - CountrySelectorViewControllerDelegate

extension ShippingViewController: CountrySelectorViewControllerDelegate {

    func countrySelectorDidSelect(country: Country) {
        presenter.update(country: country)
    }
}
