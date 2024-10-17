//
//  MapViewControllerRepresentable.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/16.
//

import SwiftUI

struct MapViewControllerRepresentable: UIViewControllerRepresentable {
    let capsule: Capsule

    func makeUIViewController(context: Context) -> UINavigationController {
        let mapViewController = MapViewController(capsule: capsule)
        let navigationController = UINavigationController(rootViewController: mapViewController)
        navigationController.modalPresentationStyle = .fullScreen

        return navigationController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}
