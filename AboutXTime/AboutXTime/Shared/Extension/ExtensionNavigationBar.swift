//
//  ExtensionNavigationBar.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/24.
//

import Foundation
import UIKit
import SwiftUI

extension UINavigationBar {
    static func setGlobalBackButtonAppearance() {

        let backButtonAppearance = UIBarButtonItem.appearance()
        backButtonAppearance.setTitleTextAttributes([.foregroundColor: UIColor.clear], for: .normal)

        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.tintColor = STColor.CC1.uiColor.withAlphaComponent(0.5)
        navigationBarAppearance.isTranslucent = true
        navigationBarAppearance.setBackgroundImage(UIImage(), for: .default)
        navigationBarAppearance.shadowImage = UIImage()
    }
}

extension UINavigationItem {
    func setGlobalBackButtonText() {
        let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
       self.backBarButtonItem = backButton
    }
}

extension UIViewController {
    func setGlobalNavigaionBarAppearance() {
        if (navigationController?.navigationBar) != nil {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = .clear

            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UINavigationBar.appearance().isTranslucent = true
        }
    }

    func clearVisualEffectView() {
        for subview in view.subviews {
            if let visualEffectView = subview as? UIVisualEffectView {
                visualEffectView.effect = nil
                visualEffectView.backgroundColor = .clear
                visualEffectView.isHidden = true
            }
        }
    }
}
