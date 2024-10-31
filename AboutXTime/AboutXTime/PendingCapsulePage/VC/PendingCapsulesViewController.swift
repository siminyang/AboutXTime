//
//  PendingCapsulesViewController.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/13.
//

import UIKit
import SwiftUI

class PendingCapsulesViewController: UIViewController {
    private var capsules: [Capsule] = []
    private var hostingController: UIHostingController<PendingCapsulesView>?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        tabBarController?.tabBar.isHidden = false
        navigationItem.setGlobalBackButtonText()
        UINavigationBar.setGlobalBackButtonAppearance()
        setGlobalNavigaionBarAppearance()
        clearVisualEffectView()

        fetchCapsules()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    private func fetchCapsules() {

        guard let userId = UserDefaults.standard.string(forKey: "userUID") else {
            print("Failed to get UID from UserDefaults.")
            return
        }

        FirebaseManager.shared.fetchUserCapsules(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let capsules):
                    self?.capsules = capsules
                    self?.delayContentUpdate()
                    print(">>>>>>> Fetched capsules: \(capsules)")
                case .failure(let error):
                    print("Error fetching capsules: \(error.localizedDescription)")
                }
            }
        }
    }

    private func delayContentUpdate() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.setupContentView()
        }
    }

    private func setupContentView() {
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
