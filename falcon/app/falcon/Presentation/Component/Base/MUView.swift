//
//  MUView.swift
//  falcon
//
//  Created by Manu Herrera on 15/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import UIKit

class MUView: UIView {

    var toast: ToastView?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubviews()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }

    func initSubviews() {
        instantiateFromNib()
        setUp()
    }

    func setUp() {
       // every view should override this method
    }

    private func instantiateFromNib() {
        let className = String(describing: type(of: self))
            .components(separatedBy: ".")
            .first!

        let nib = UINib(nibName: className, bundle: Bundle(for: type(of: self)))

        if let view = nib.instantiate(withOwner: self, options: nil).first as? UIView {
            view.frame = bounds
            addSubview(view)
        }
    }

    func addTo(_ view: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(self)
        self.frame = view.bounds

        self.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        self.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        self.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }

}

extension MUView: DisplayableToast {

    var view: UIView! {
        return self
    }

    @objc func dismissToast() {
        toast?.animateOut()
    }

}

extension MUView: BasePresenterDelegate {

    func pushTo(_ vc: MUViewController) {
        if let currentVc = self.parentViewController {
            currentVc.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func showMessage(_ message: String) {
        showToast(message: message)
    }

}
