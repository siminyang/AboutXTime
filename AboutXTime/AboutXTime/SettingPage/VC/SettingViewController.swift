//
//  SettingViewController.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/29.
//

import UIKit
import SwiftUI
import Foundation

class SettingViewController: UIViewController {
    private var viewModel = SettingsViewModel()
    var onDismiss: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        let settingsView = SettingsView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: settingsView)
        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        hostingController.didMove(toParent: self)

        setupCloseButton()
        setupViewModelCallbacks()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        onDismiss?()
    }

    private func setupCloseButton() {
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .white
        closeButton.addTarget(self, action: #selector(closeSettings), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(closeButton)

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
    }

    @objc private func closeSettings() {
        dismiss(animated: true, completion: nil)
    }

    private func setupViewModelCallbacks() {
        viewModel.onLogout = { [weak self] in
            self?.navigateToLoginPage()
        }

        viewModel.onDeleteAccount = { [weak self] in
            self?.navigateToLoginPage()
        }

        viewModel.onError = { [weak self] errorMessage in
            self?.displayError(message: errorMessage)
        }
    }

    private func navigateToLoginPage() {
        let loginPageVC = LoginViewController()

        let navigationController = UINavigationController(rootViewController: loginPageVC)

        if let window = UIApplication.shared.windows.first {
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
        }
    }

    private func displayError(message: String) {
        let alert = UIAlertController(title: "錯誤", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "確定", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
