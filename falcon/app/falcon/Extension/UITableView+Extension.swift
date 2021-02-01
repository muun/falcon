//
//  UITableView+Extension.swift
//  falcon
//
//  Created by Manu Herrera on 29/03/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit

extension UITableView {

    func dequeue<T: UITableViewCell>(type: T.Type, indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.idCell, for: indexPath) as? T else {
            fatalError("Could not dequeue cell of type \(T.idCell)")
        }

        return cell
    }

    func register<T: UITableViewCell>(type: T.Type) {
        register(T.cellNib, forCellReuseIdentifier: T.idCell)
    }

}
