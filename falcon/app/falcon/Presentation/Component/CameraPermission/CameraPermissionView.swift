//
//  CameraPermissionView.swift
//  falcon
//
//  Created by Manu Herrera on 03/01/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit

protocol CameraPermissionViewDelegate: AnyObject {
    func userDidRequestPermission()
}

class CameraPermissionView: MUView {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var contentLabel: UILabel!
    @IBOutlet private weak var buttonView: ButtonView!

    weak var delegate: CameraPermissionViewDelegate?

    public var titleText: String {
        get { return titleLabel.text ?? "" }
        set { titleLabel.text = newValue }
    }

    public var contentText: String {
        get { return contentLabel.text ?? "" }
        set { contentLabel.text = newValue }
    }

    override func setUp() {
        setUpLabels()
        setUpButton()

        makeViewTestable()
    }

    fileprivate func setUpLabels() {
        titleLabel.textColor = Asset.Colors.title.color
        titleLabel.font = Constant.Fonts.system(size: .h2, weight: .medium)

        contentLabel.style = .description
    }

    fileprivate func setUpButton() {
        buttonView.delegate = self
        buttonView.buttonText = L10n.CameraPermissionView.s1
        buttonView.isEnabled = true
    }

}

extension CameraPermissionView: ButtonViewDelegate {

    func button(didPress button: ButtonView) {
        delegate?.userDidRequestPermission()
    }

}

extension CameraPermissionView: UITestablePage {
    typealias UIElementType = UIElements.CustomViews.CameraPermissionPage

    func makeViewTestable() {
        makeViewTestable(buttonView, using: .enable)
    }
}
