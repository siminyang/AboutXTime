//
//  ShowCapsulePageViewController.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/15.
//

import UIKit
import SwiftUI

class ShowCapsulePageViewController: UIViewController {

    private let capsule: Capsule
    var dismissHandler: (() -> Void)?

    init(capsule: Capsule) {
        self.capsule = capsule
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        setupUI()
        setupGesture()
        tabBarController?.tabBar.isHidden = true
        UINavigationBar.setGlobalBackButtonAppearance()
        setGlobalNavigaionBarAppearance()
        clearVisualEffectView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    private func setupUI() {
        let showPageTabView = UIHostingController(
            rootView: ShowCapsuleTabView(capsule: capsule, isPresented: .constant(true))
        )

        addChild(showPageTabView)
        view.addSubview(showPageTabView.view)

        showPageTabView.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            showPageTabView.view.topAnchor.constraint(equalTo: view.topAnchor),
            showPageTabView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            showPageTabView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            showPageTabView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        showPageTabView.didMove(toParent: self)
    }

    private func setupGesture() {
        let edgePanGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgePan(_:)))
        edgePanGesture.edges = .left
        view.addGestureRecognizer(edgePanGesture)
    }

    @objc private func handleEdgePan(_ gesture: UIScreenEdgePanGestureRecognizer) {
        switch gesture.state {
        case .began:
            print("開始手勢")
        case .recognized:
            print("手勢已識別，返回上一頁")
            dismissHandler?()
        case .ended, .cancelled:
            print("手勢結束")
        default:
            break
        }
    }
}
