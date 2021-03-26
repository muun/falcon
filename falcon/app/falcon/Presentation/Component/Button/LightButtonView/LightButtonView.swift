//
//  LightButtonView.swift
//  falcon
//
//  Created by Manu Herrera on 20/04/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

protocol LightButtonViewDelegate: class {
    func lightButton(didPress lightButton: LightButtonView)
}

@IBDesignable
class LightButtonView: MUView {

    @IBOutlet fileprivate weak var button: UIButton!

    weak var delegate: LightButtonViewDelegate?

    public var buttonText: String {
        get { return button.titleLabel?.text ?? "" }
        set { button.setTitle(newValue, for: .normal) }
    }

    override func setUp() {
        setUpButton()
    }

    private func setUpButton() {
        button.setTitle(nil, for: .normal)
        button.setTitleColor(Asset.Colors.muunBlue.color, for: .normal)
        button.titleLabel?.font = Constant.Fonts.system(size: .helper, weight: .semibold)
        button.backgroundColor = Asset.Colors.muunBluePale.color

        button.roundCorners()
    }

    @IBAction fileprivate func buttonPressed(_ sender: Any) {
        delegate?.lightButton(didPress: self)
    }

}
