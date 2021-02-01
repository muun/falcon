//
//  RepresentableView.swift
//  falcon
//
//  Created by Manu Herrera on 24/06/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import SwiftUI

/**
 This struct is used to display previews in Xcode's canvas.
 The only thing you need to do is replace the return statement of the `makeUIView` method with the
 view you want to be previewed.
 */
struct RepresentableView: UIViewRepresentable {

    func makeUIView(context: Context) -> UIView {
        // Remember that the view must be a final class
        return NotificationsPrimingView(delegate: nil)
    }

    func updateUIView(_ view: UIView, context: Context) {}

}

@available(iOS 13.0.0, *)
struct Preview: PreviewProvider {
    static var previews: some View {
        RepresentableView()
    }
}
