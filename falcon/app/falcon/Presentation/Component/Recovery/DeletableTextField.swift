//
//  RecoveryCodeTextField.swift
//  falcon
//
//  Created by Manu Herrera on 03/06/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

protocol DeletableTextFieldDelegate: AnyObject {
    func textFieldDidDelete(_ textField: DeletableTextField)
}

// We need to override the textfield to access the delete backward method
class DeletableTextField: UITextField {

    weak var deleteDelegate: DeletableTextFieldDelegate?

    override func deleteBackward() {
        super.deleteBackward()
        deleteDelegate?.textFieldDidDelete(self)
    }

}
