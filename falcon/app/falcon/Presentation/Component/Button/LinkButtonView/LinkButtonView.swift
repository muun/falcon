//
//  LinkButtonView.swift
//  falcon
//
//  Created by Manu Herrera on 31/10/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import UIKit

protocol LinkButtonViewDelegate: AnyObject {
    func linkButton(didPress linkButton: LinkButtonView)
}

@IBDesignable
class LinkButtonView: MUView {

    @IBOutlet private weak var button: UIButton!

    weak var delegate: LinkButtonViewDelegate?

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
        button.setTitleColor(Asset.Colors.muunBlue.color, for: .normal)
    }

    fileprivate func setEnabled(_ isEnabled: Bool) {
        let nextColor: UIColor = isEnabled
            ? Asset.Colors.muunBlue.color
            : Asset.Colors.muunGrayLight.color

        self.button.setTitleColor(nextColor, for: .normal)
        self.button.isUserInteractionEnabled = isEnabled
    }

    @IBAction fileprivate func buttonPressed(_ sender: Any) {
        delegate?.linkButton(didPress: self)
    }

}

extension LinkButtonView: UITestablePage {

    typealias UIElementType = UIElements.CustomViews.LinkButtonPage

    func makeViewTestable() {
        makeViewTestable(button, using: .mainButton)
    }

}
