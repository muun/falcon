//
//  QRLoadingView.swift
//  falcon
//
//  Created by Federico Bond on 22/02/2021.
//  Copyright © 2021 muun. All rights reserved.
//

import UIKit

class QRLoadingView: UIView {

    private let label = UILabel()
    private let activityIndicator = UIActivityIndicatorView()

    var text: String? {
        get {
            return label.text
        }
        set {
            label.text = newValue
        }
    }

    init() {
        super.init(frame: .zero)
        setUpView()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView() {
        backgroundColor = Asset.Colors.muunAlmostWhite.color

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        addSubview(container)

        label.text = "Loading"
        label.font = Constant.Fonts.system(size: .helper)
        label.textColor = Asset.Colors.muunGrayDark.color
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: centerXAnchor),
            container.centerYAnchor.constraint(equalTo: centerYAnchor),
            container.widthAnchor.constraint(equalTo: widthAnchor),
            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            label.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 8),
            activityIndicator.centerXAnchor.constraint(equalTo: container.centerXAnchor)
        ])

        activityIndicator.startAnimating()
    }

}
