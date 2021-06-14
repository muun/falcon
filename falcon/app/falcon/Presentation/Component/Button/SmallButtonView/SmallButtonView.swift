//
//  SmallButtonView.swift
//  falcon
//
//  Created by Manu Herrera on 04/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit

protocol SmallButtonViewDelegate: AnyObject {
    func button(didPress button: SmallButtonView)
}

@IBDesignable
class SmallButtonView: MUView {

    @IBOutlet private weak var button: UIButton!
    weak var delegate: SmallButtonViewDelegate?

    public var isEnabled: Bool {
        get { return button.isUserInteractionEnabled }
        set { setEnabled(newValue) }
    }

    public var buttonText: String {
        get { return button.titleLabel!.text ?? "" }
        set { button.setTitle(newValue, for: .normal) }
    }

    override func setUp() {
        setUpButton()

        makeViewTestable()
    }

    private func setUpButton() {
        button.layer.cornerRadius = 4
        button.clipsToBounds = true
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = Asset.Colors.muunBlue.color
    }

    fileprivate func setEnabled(_ isEnabled: Bool) {
        UIView.animate(
            withDuration: 0.25,
            animations: {
                if isEnabled {
                    self.alpha = 1.0
                } else {
                    self.alpha = 0.2
                }
        },
            completion: { _ in
                self.button.isUserInteractionEnabled = isEnabled
        })

        layoutSubviews()
    }

    @IBAction fileprivate func buttonTouched(_ sender: SmallButtonView) {
        delegate?.button(didPress: self)
    }
}

extension SmallButtonView: UITestablePage {
    typealias UIElementType = UIElements.CustomViews.SmallButtonViewPage

    func makeViewTestable() {
        self.makeViewTestable(self.button, using: .mainButton)
    }
}
