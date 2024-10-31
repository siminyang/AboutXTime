//
//  OpenedCapsulesViewController.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/13.
//

import UIKit
import SwiftUI
import Combine
import NVActivityIndicatorView

class OpenedCapsulesViewController: UIViewController {

    private let viewModel = OpenedCapsulesViewModel()
    private var cancellables = Set<AnyCancellable>()
    private var loadingIndicator: NVActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        UINavigationBar.setGlobalBackButtonAppearance()
        navigationItem.setGlobalBackButtonText()

        setupLoadingIndicator()
        observeViewModel()
        viewModel.fetchCapsulesInBackground()
    }

    private func observeViewModel() {
        viewModel.$birthDate
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.tryDisplayOpenedCapsulesView()
            }
            .store(in: &cancellables)

        viewModel.$isLoading
            .receive(on: RunLoop.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.showLoadingIndicator()
                } else {
                    self?.removeLoadingIndicator()
                }
            }
            .store(in: &cancellables)
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
            rootView: OpenedCapsulesView(viewModel: viewModel, userBirthDate: birthDate)
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

    private func setupLoadingIndicator() {
        let frame = CGRect(x: 0, y: 0, width: 80.0, height: 80.0)
        loadingIndicator = NVActivityIndicatorView(frame: frame, type: .orbit, color: STColor.CC2.uiColor)
        loadingIndicator?.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicator!)

        NSLayoutConstraint.activate([
            loadingIndicator!.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator!.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func showLoadingIndicator() {
        loadingIndicator?.startAnimating()
    }

    private func removeLoadingIndicator() {
        loadingIndicator?.stopAnimating()
        loadingIndicator?.removeFromSuperview()
    }
}
