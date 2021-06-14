//
//  ChevronView.swift
//  falcon
//
//  Created by Manu Herrera on 30/11/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit
import Lottie
import core

protocol ChevronViewDelegate: AnyObject {
    func chevronTap()
}

final class ChevronView: UIView {

    private var contentView: UIView! = UIView()
    private var chevronLottieView: AnimationView! = AnimationView()

    private weak var delegate: ChevronViewDelegate?

    init(delegate: ChevronViewDelegate?) {
        self.delegate = delegate
        super.init(frame: .zero)

        setUpView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView() {
        setUpContentView()
        setUpLottieView()
    }

    private func setUpContentView() {
        contentView.isUserInteractionEnabled = true
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: .chevronTap)
        swipeGesture.direction = .up
        contentView.addGestureRecognizer(swipeGesture)
        contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: .chevronTap))
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)

        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    fileprivate func setUpLottieView() {

        chevronLottieView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(chevronLottieView)

        NSLayoutConstraint.activate([
            chevronLottieView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            chevronLottieView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chevronLottieView.heightAnchor.constraint(equalToConstant: 56),
            chevronLottieView.widthAnchor.constraint(equalToConstant: 56)
        ])

        chevronLottieView.contentMode = .scaleAspectFit
        chevronLottieView.loopMode = .loop
    }

    @objc func chevronTap() {
        delegate?.chevronTap()
    }

    private func isDarkMode() -> Bool {
        if #available(iOS 12.0, *) {
            return self.traitCollection.userInterfaceStyle == .dark
        }

        return false
    }

    private func setAnimation(name: String) {
        chevronLottieView.animation = Animation.named(name)
        chevronLottieView.play()
    }

    // MARK: - Actions -

    func updateOperationsState(_ style: core.OperationsState) {
        if isDarkMode() {
            switch style {
            case .confirmed: setAnimation(name: "dm_chevron-regular")
            case .pending: setAnimation(name: "dm_chevron-pending")
            case .cancelable: setAnimation(name: "dm_chevron-rbf")
            }
        } else {
            switch style {
            case .confirmed: setAnimation(name: "lm_chevron-regular")
            case .pending: setAnimation(name: "lm_chevron-pending")
            case .cancelable: setAnimation(name: "lm_chevron-rbf")
            }
        }
    }

}

fileprivate extension Selector {
    static let chevronTap = #selector(ChevronView.chevronTap)
}
