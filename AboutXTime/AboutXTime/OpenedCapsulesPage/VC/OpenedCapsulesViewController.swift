//
//  OpenedCapsulesViewController.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/13.
//

import UIKit
import SwiftUI
import Combine
import Firebase
import NVActivityIndicatorView

class OpenedCapsulesViewController: UIViewController {

    private let viewModel = OpenedCapsulesViewModel()
    private var capsules: [Capsule] = []
    private var cancellables = Set<AnyCancellable>()
    private var loadingIndicator: NVActivityIndicatorView?
    private var isLoading = false
    private var listener: ListenerRegistration?

    var onCapsulesUpdated: (([Capsule]) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        UINavigationBar.setGlobalBackButtonAppearance()
        navigationItem.setGlobalBackButtonText()

        observeViewModel()
        initializeLoadingIndicator()
        fetchCapsulesInBackground()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        initializeLoadingIndicator()
        fetchCapsulesInBackground()
    }

    private func observeViewModel() {
        viewModel.$birthDate
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.tryDisplayOpenedCapsulesView()
            }
            .store(in: &cancellables)
    }

    private func initializeLoadingIndicator() {
        let frame = CGRect(x: 0, y: 0, width: 80.0, height: 80.0)
        loadingIndicator = NVActivityIndicatorView(frame: frame, type: .orbit, color: STColor.CC2.uiColor)

        if let loadingIndicator = loadingIndicator {
            loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(loadingIndicator)

            NSLayoutConstraint.activate([
                loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])

            loadingIndicator.startAnimating()
        }
    }

    private func showLoadingIndicator() {
        loadingIndicator?.startAnimating()
    }

    private func removeLoadingIndicator() {
        loadingIndicator?.stopAnimating()
        loadingIndicator?.removeFromSuperview()
    }

    private func fetchCapsulesInBackground() {
        guard !isLoading else { return }    // isloading = true的話跳出，防止重複觸發資料加載操作
        isLoading = true
        showLoadingIndicator()

        DispatchQueue.global(qos: .background).async { [weak self] in

            guard let userId = UserDefaults.standard.string(forKey: "userUID") else {
                print("Failed to get UID from UserDefaults.")
                return
            }

            self?.listener = FirebaseManager.shared.fetchUserCapsules(userId: userId) { [weak self] result in
                DispatchQueue.main.async {
                    self?.removeLoadingIndicator()
                    self?.isLoading = false

                    switch result {
                    case .success(let capsules):
                        self?.capsules = capsules
                        print(">>>>>>> Fetched openedcapsules: \(capsules)")
                        self?.onCapsulesUpdated?(capsules)
                        self?.tryDisplayOpenedCapsulesView()

                    case .failure(let error):
                        print("Error fetching capsules: \(error.localizedDescription)")
                        self?.tryDisplayOpenedCapsulesView()
                    }
                }
            }
        }
    }

    private func tryDisplayOpenedCapsulesView() {
        if viewModel.birthDate != nil {
            setupOpenedCapsulesView()
        } else if viewModel.needsBirthDate {
            presentBirthDateSheet()
        }
    }

    private func presentBirthDateSheet() {
        let birthYearVC = BirthYearViewController(viewModel: viewModel)
        let navController = UINavigationController(rootViewController: birthYearVC)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true, completion: nil)
    }

    private func setupOpenedCapsulesView() {
        guard let birthDate = viewModel.birthDate else { return }
        let capsulesView = UIHostingController(
            rootView: OpenedCapsulesView(capsules: capsules, userBirthDate: birthDate)
        )
        addChild(capsulesView)
        view.addSubview(capsulesView.view)
        capsulesView.view.frame = view.bounds
        capsulesView.didMove(toParent: self)

        NSLayoutConstraint.activate([
            capsulesView.view.topAnchor.constraint(equalTo: view.topAnchor),
            capsulesView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            capsulesView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            capsulesView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}
