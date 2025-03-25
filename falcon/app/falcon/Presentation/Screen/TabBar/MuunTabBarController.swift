//
//  MuunTabBarController.swift
//  falcon
//
//  Created by Manu Herrera on 27/11/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

class MuunTabBarController: UITabBarController {

    override init(nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setUpView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView() {
        setUpTabBarStyle()
        setUpScreens()

        hidesBottomBarWhenPushed = true
    }

    fileprivate func setUpTabBarStyle() {
        tabBar.isTranslucent = false
        tabBar.barTintColor = Asset.Colors.cellBackground.color
        tabBar.tintColor = Asset.Colors.muunBlue.color
        tabBar.unselectedItemTintColor = Asset.Colors.muunGrayLight.color

        UITabBarItem.appearance().setTitleTextAttributes(
            [NSAttributedString.Key.font: Constant.Fonts.system(size: .tabBar, weight: .semibold)], for: .normal
        )
        UITabBarItem.appearance().setTitleTextAttributes(
            [NSAttributedString.Key.font: Constant.Fonts.system(size: .tabBar, weight: .bold)], for: .selected
        )
    }

    fileprivate func setUpScreens() {
        let homeNC = UINavigationController()
        let homeVC = HomeViewController()
        homeVC.tabBarItem = UITabBarItem(
            title: L10n.AppDelegate.walletTab,
            image: Asset.Assets.actionCardReceive.image,
            tag: 0
        )
        homeNC.setViewControllers([homeVC], animated: true)

        let secCenterNC = UINavigationController()
        let secCenterVC = SecurityCenterViewController(origin: .shieldButton)
        secCenterVC.tabBarItem = UITabBarItem(
            title: L10n.AppDelegate.securityTab,
            image: Asset.Assets.securityCenter.image,
            tag: 1
        )
        secCenterNC.setViewControllers([secCenterVC], animated: true)

        let settingsNC = UINavigationController()
        let settingsVc = SettingsViewController()
        settingsVc.tabBarItem = UITabBarItem(
            title: L10n.AppDelegate.settingsTab,
            image: Asset.Assets.settings.image,
            tag: 2
        )
        settingsNC.setViewControllers([settingsVc], animated: true)

        setViewControllers([homeNC, secCenterNC, settingsNC], animated: true)
    }

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {

        // Override origin for Security Center so it gets logged correctly
        if item.tag == 1 {
            SecurityCenterViewController.origin = .shieldButton
        }

        // find index if the selected tab bar item, then find the corresponding view and get its image,
        // the view position is offset by 1 because the first item is the background (at least in this case)
        guard let idx = tabBar.items?.firstIndex(of: item),
              tabBar.subviews.count > idx + 1,
              let imageView = tabBar.subviews[idx + 1].subviews.compactMap({ $0 as? UIImageView }).first else {
            return
        }

        UIView.animate(withDuration: 0.15, animations: {
            imageView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: { _ in
            UIView.animate(withDuration: 0.15, animations: {
                imageView.transform = CGAffineTransform.identity
            })
        })
    }
}
