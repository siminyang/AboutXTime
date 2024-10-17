//
//  ShowCapsulePageRepresentable.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/15.
//

import Foundation
import SwiftUI

struct ShowCapsulePageRepresentable: UIViewControllerRepresentable {
    let capsule: Capsule
    @Binding var isPresented: Bool

    func makeUIViewController(context: Context) -> UINavigationController {
        let viewController = ShowCapsulePageViewController(capsule: capsule)
        let navigationController = UINavigationController(rootViewController: viewController)

        return navigationController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}
