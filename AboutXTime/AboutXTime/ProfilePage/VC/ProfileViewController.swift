//
//  ProfileViewController.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/13.
//

import UIKit
import SwiftUI
import AuthenticationServices
import FirebaseAuth
import CryptoKit

class ProfileViewController: UIViewController {

    private let hiddenView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupBackgroundView()
        setupHiddenView()

        guard let userID = UserDefaults.standard.string(forKey: "userUID") else {
            print("User ID not found in UserDefaults")
            return
        }

        let profileView = UIHostingController(rootView: ProfileView(userID: userID))
        addChild(profileView)
        profileView.view.frame = view.bounds
        profileView.view.backgroundColor = UIColor.clear
        view.addSubview(profileView.view)
        profileView.didMove(toParent: self)

        setupOptionsButton()
    }

    func setupBackgroundView() {
        let logoLabel = UILabel()
        logoLabel.text = "© 2024"
        logoLabel.textColor = .gray
        logoLabel.font = UIFont.systemFont(ofSize: 14, weight: .light)
        logoLabel.textAlignment = .center
        logoLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(logoLabel)

        NSLayoutConstraint.activate([
            logoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40)
        ])
    }

    func setupOptionsButton() {
        let optionsButton = UIButton(type: .system)
        optionsButton.setTitle("⋮", for: .normal)
        optionsButton.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        optionsButton.setTitleColor(.white, for: .normal)
        optionsButton.addTarget(self, action: #selector(showSettings), for: .touchUpInside)
        optionsButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(optionsButton)

        NSLayoutConstraint.activate([
            optionsButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            optionsButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])

        view.bringSubviewToFront(optionsButton)
    }

    private func setupHiddenView() {
        view.addSubview(hiddenView)

        NSLayoutConstraint.activate([
            hiddenView.topAnchor.constraint(equalTo: view.topAnchor),
            hiddenView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hiddenView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hiddenView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc func showSettings() {
        let settingsVC = SettingViewController()
        settingsVC.modalPresentationStyle = .pageSheet
        settingsVC.isModalInPresentation = false

        if let sheet = settingsVC.sheetPresentationController {
            sheet.detents = [.custom { _ in 150 }]
            sheet.prefersGrabberVisible = true // 顯示拖動手柄
        }

        hiddenView.isHidden = false

        settingsVC.onDismiss = { [weak self] in
            self?.hiddenView.isHidden = true
        }

        present(settingsVC, animated: true, completion: nil)
    }
}
