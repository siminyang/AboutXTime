//
//  ActivityIndicatorView.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/10/1.
//

import Foundation
import SwiftUI
import NVActivityIndicatorView

struct ActivityIndicatorView: UIViewRepresentable {
    var type: NVActivityIndicatorType
    var color: UIColor
    var padding: CGFloat?

    @Binding var isAnimating: Bool

    func makeUIView(context: Context) -> NVActivityIndicatorView {
        let activityIndicatorView = NVActivityIndicatorView(frame: .zero, type: type, color: color, padding: padding)
        return activityIndicatorView
    }

    func updateUIView(_ uiView: NVActivityIndicatorView, context: Context) {
        if isAnimating {
            uiView.startAnimating()
        } else {
            uiView.stopAnimating()
        }
    }
}
