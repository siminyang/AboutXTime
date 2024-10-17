//
//  ExtensionTabBar.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/10/17.
//

import Foundation
import UIKit

extension UITabBar {
    static func setGlobalTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black
        appearance.shadowImage = nil
        appearance.shadowColor = .clear
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}
