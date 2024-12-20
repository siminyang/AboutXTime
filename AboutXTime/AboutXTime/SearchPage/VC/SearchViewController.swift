//
//  SearchViewController.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/19.
//

import UIKit
import SwiftUI
import NVActivityIndicatorView

class SearchViewController: UIViewController {

    var capsules: [Capsule] = []
    var userBirthDate: Date
    var onCapsulesUpdated: (([Capsule]) -> Void)?

    init(capsules: [Capsule], userBirthDate: Date, onCapsulesUpdated: (([Capsule]) -> Void)? = nil) {
        self.capsules = capsules
        self.userBirthDate = userBirthDate
        self.onCapsulesUpdated = onCapsulesUpdated
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        UINavigationBar.setGlobalBackButtonAppearance()
        setGlobalNavigaionBarAppearance()
        navigationItem.setGlobalBackButtonText()

        let searchPageView = UIHostingController(
            rootView: SearchPageView(capsules: capsules,
                                     userBirthDate: userBirthDate))
        addChild(searchPageView)
        searchPageView.view.frame = view.bounds
        searchPageView.view.backgroundColor = UIColor.black
        view.addSubview(searchPageView.view)

        searchPageView.didMove(toParent: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let navigationBar = navigationController?.navigationBar {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()

            let backButtonAppearance = UIBarButtonItemAppearance()
            backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
            appearance.backButtonAppearance = backButtonAppearance

            let buttonAppearance = UIBarButtonItemAppearance()
            buttonAppearance.normal.titleTextAttributes = [.foregroundColor: STColor.CC1.color]
            appearance.buttonAppearance = buttonAppearance

            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
            navigationBar.compactAppearance = appearance
            navigationBar.isTranslucent = false
            navigationBar.backgroundColor = .black
        }
        let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButton

        tabBarController?.tabBar.isHidden = false
    }

    func updateCapsules(_ updatedCapsules: [Capsule]) {
        self.capsules = updatedCapsules
    }
}
