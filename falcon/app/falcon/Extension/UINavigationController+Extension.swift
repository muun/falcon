//
//  UINavigationController+Extension.swift
//  falcon
//
//  Created by Manu Herrera on 29/11/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import UIKit

extension UINavigationController {

    func pushViewController(_ viewController: UIViewController, animated: Bool, removeFromStack: Bool = false) {

        if removeFromStack {
            var navigationArray = self.viewControllers // To get all UIViewController stack as Array
            navigationArray.remove(at: (navigationArray.count) - 1) // To remove previous UIViewController
            self.setViewControllers(navigationArray, animated: false)
        }

        pushViewController(viewController, animated: animated)

    }

    func popTo<T: MUViewController>(type: T.Type) {
        for vc in viewControllers where vc.isKind(of: type) {
            popToViewController(vc, animated: true)
            break
        }
    }

    func hideSeparatorForModal() {
        hideSeparator()
        navigationBar.barTintColor = Asset.Colors.background.color
        view.backgroundColor = Asset.Colors.background.color
    }

    func hideSeparator() {
        navigationBar.shadowImage = UIColor.clear.as1ptImage()
    }

    func showSeparator() {
        navigationBar.shadowImage = Asset.Colors.separator.color.as1ptImage()
    }

}
