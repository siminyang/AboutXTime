//
//  SearchViewControllerRepresentable.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/19.
//

import SwiftUI
import UIKit

struct SearchViewControllerRepresentable: UIViewControllerRepresentable {
    let capsules: [Capsule]
    let userBirthDate: Date

    func makeUIViewController(context: Context) -> SearchViewController {
        return SearchViewController(capsules: capsules, userBirthDate: userBirthDate)
    }

    func updateUIViewController(_ uiViewController: SearchViewController, context: Context) {
        uiViewController.updateCapsules(capsules)
    }
}
