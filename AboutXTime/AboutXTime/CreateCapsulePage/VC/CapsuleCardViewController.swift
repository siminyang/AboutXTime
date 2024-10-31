//
//  CapsuleCardViewController.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/13.
//

import UIKit
import SwiftUI

class CapsuleCardViewController: UIViewController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {

    private var viewModel: CardViewModel
    private var isAlertShown = false

    init(viewModel: CardViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(resetToInitialCreationPageAndNavigateToPending),
                                               name: .resetCreationPageAndNavigateToPending,
                                               object: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self

        let capsuleCardView = CapsuleCardTabView(viewModel: viewModel)
        let capsuleCardViewController = UIHostingController(rootView: capsuleCardView)
        addChild(capsuleCardViewController)
        capsuleCardViewController.view.frame = self.view.bounds
        self.view.addSubview(capsuleCardViewController.view)
        capsuleCardViewController.didMove(toParent: self)

        print(">>>> CapsuleCardViewController loaded with capsuleId: \(viewModel.capsuleId ?? "nil")")

        setupCustomBackButton()
    }

    private func setupCustomBackButton() {
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
    }

    @objc private func backButtonTapped() {
        showExitConfirmationAlert()
    }

    private func showExitConfirmationAlert() {
        let alert = UIAlertController(title: "確定要返回嗎？", message: "您剛剛建立的膠囊內容將會被清空喔～", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { _ in
            self.isAlertShown = false
        }))

        alert.addAction(UIAlertAction(title: "確定", style: .destructive, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))

        present(alert, animated: true, completion: nil)
    }

    func navigationController(_ navigationController: UINavigationController,
                              shouldPop viewController: UIViewController) -> Bool {
            if isAlertShown {
                return true
            } else {
                showExitConfirmationAlert()
                return false
            }
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if navigationController?.viewControllers.count ?? 0 > 1 {
            showExitConfirmationAlert()
            return false
        }
        return true
    }

    @objc private func resetToInitialCreationPageAndNavigateToPending() {
        let createCapsulesVC = CreateCapsulesViewController()
        if let tabBarController = self.navigationController?.tabBarController {
            self.navigationController?.setViewControllers([createCapsulesVC], animated: false)
            tabBarController.selectedIndex = 0
        }
    }
}
