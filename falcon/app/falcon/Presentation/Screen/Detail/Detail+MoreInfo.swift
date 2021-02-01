//
//  Detail+MoreInfo.swift
//  falcon
//
//  Created by Federico Bond on 08/12/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import Foundation

extension BottomDrawerInfo {

    static let rbf: MoreInfo = MoreInfo(
        title: L10n.DetailViewController.rbfInfoTitle,
        description: L10n.DetailViewController.rbfInfoDesc.attributedForDescription(),
        type: .rbf,
        action: nil
    )
}
