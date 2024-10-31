//
//  PendingCapsulesViewController.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/13.
//

import UIKit
import SwiftUI
import Combine

class PendingCapsulesViewController: UIViewController {
    private var hostingController: UIHostingController<PendingCapsulesView>?
    private var viewModel = PendingCapsulesViewModel()
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        tabBarController?.tabBar.isHidden = false
        navigationItem.setGlobalBackButtonText()
        UINavigationBar.setGlobalBackButtonAppearance()
        setGlobalNavigaionBarAppearance()
        clearVisualEffectView()

        setUpBinding()
        viewModel.fetchCapsules()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    private func setUpBinding() {
        viewModel.$capsules
            .receive(on: DispatchQueue.main)
            .sink { [weak self] capsules in
                self?.setupContentView(with: capsules)
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { errorMessage in
                if let errorMessage = errorMessage {
                    print("Error fetching capsules \(errorMessage)")
                }
            }
            .store(in: &cancellables)
    }

    private func setupContentView(with capsules: [Capsule]) {
        let contentView = PendingCapsulesView(capsules: capsules)
        let hostingController = UIHostingController(rootView: contentView)

        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(hostingController.view)

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])

        hostingController.didMove(toParent: self)

        self.hostingController = hostingController
    }
}
