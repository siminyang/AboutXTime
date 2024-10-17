//
//  VisualEffectBlurView.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/30.
//

import Foundation
import SwiftUI

struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style
    var colorTint: UIColor
    var colorTintAlpha: CGFloat

    func makeUIView(context: Context) -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: blurStyle)
        let blurView = UIVisualEffectView(effect: blurEffect)

        let colorView = UIView()
        colorView.backgroundColor = colorTint
        colorView.alpha = colorTintAlpha
        colorView.translatesAutoresizingMaskIntoConstraints = false
        blurView.contentView.addSubview(colorView)

        NSLayoutConstraint.activate([
            colorView.widthAnchor.constraint(equalTo: blurView.widthAnchor),
            colorView.heightAnchor.constraint(equalTo: blurView.heightAnchor),
            colorView.centerXAnchor.constraint(equalTo: blurView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: blurView.centerYAnchor)
        ])

        return blurView
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        if let colorView = uiView.contentView.subviews.first {
            colorView.backgroundColor = colorTint
            colorView.alpha = colorTintAlpha
        }
        uiView.effect = UIBlurEffect(style: blurStyle)
    }
}
