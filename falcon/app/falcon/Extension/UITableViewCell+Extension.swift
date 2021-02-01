//
//  UITableViewCell+Extension.swift
//  falcon
//
//  Created by Manu Herrera on 05/12/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import UIKit

extension UITableViewCell {

    static internal var idCell: String {
        return String(describing: self.self)
    }

    static internal var cellNib: UINib {
        return UINib(nibName: idCell, bundle: nil)
    }

}
