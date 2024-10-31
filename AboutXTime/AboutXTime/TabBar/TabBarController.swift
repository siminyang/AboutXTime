//
//  TabBarController.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/13.
//

import UIKit
import SwiftUI
import Foundation

class TabBarController: UITabBarController {
    private let viewModel: TabBarViewModel

    init(viewModel: TabBarViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        self.selectedIndex = 1
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()

        view.overrideUserInterfaceStyle = .dark
    }

    private func setupTabs() {
        viewControllers = viewModel.tabs.enumerated().map { index, tab in
            let viewController = viewModel.viewController(for: index)
            viewController.tabBarItem = UITabBarItem(title: tab.title, image: tab.image, selectedImage: nil)
            return viewController
        }

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black

        appearance.stackedLayoutAppearance.selected.iconColor = STColor.CC1.uiColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes =
        [NSAttributedString.Key.foregroundColor: UIColor.white]
        appearance.stackedLayoutAppearance.normal.iconColor =
        UIColor.gray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes =
        [NSAttributedString.Key.foregroundColor: UIColor.gray]

        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }

        tabBar.unselectedItemTintColor = UIColor.gray.withAlphaComponent(0.5)
    }
}
