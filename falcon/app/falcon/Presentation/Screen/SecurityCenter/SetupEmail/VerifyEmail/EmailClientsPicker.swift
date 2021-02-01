//
//  EmailClientsPicker.swift
//  falcon
//
//  Created by Manu Herrera on 18/09/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

protocol EmailClientsPicker {
    var emailActionSheet: UIAlertController { get set }

    func addEmailOptions()
}

extension EmailClientsPicker {

    func addEmailOptions() {
        if let action = openAction(withURL: "message://", andTitleActionTitle: "Mail") {
            emailActionSheet.addAction(action)
        }

        if let action = openAction(withURL: "googlegmail://", andTitleActionTitle: "Gmail") {
            emailActionSheet.addAction(action)
        }

        if let action = openAction(withURL: "inbox-gmail://", andTitleActionTitle: "Inbox") {
            emailActionSheet.addAction(action)
        }

        if let action = openAction(withURL: "ms-outlook://", andTitleActionTitle: "Outlook") {
            emailActionSheet.addAction(action)
        }

        if let action = openAction(withURL: "x-dispatch:///", andTitleActionTitle: "Dispatch") {
            emailActionSheet.addAction(action)
        }

        emailActionSheet.addAction(UIAlertAction(title: L10n.EmailClientsPicker.s1, style: .cancel, handler: nil))
    }

    fileprivate func openAction(withURL: String, andTitleActionTitle: String) -> UIAlertAction? {
        guard let url = URL(string: withURL), UIApplication.shared.canOpenURL(url) else {
            return nil
        }

        let action = UIAlertAction(title: andTitleActionTitle, style: .default) { (_) in
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }

        return action
    }

}
