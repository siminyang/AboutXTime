//
//  TabBarViewModel.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/13.
//

import UIKit
import FirebaseAuth

class TabBarViewModel {
    let tabs: [TabItem] = [
        TabItem(title: "待開啟膠囊", image: UIImage(systemName: "diamond")!),
        TabItem(title: "創建膠囊", image: UIImage(systemName: "cross")!),
        TabItem(title: "已開啟膠囊", image: UIImage(systemName: "circle")!),
        TabItem(title: "個人設置", image: UIImage(systemName: "seal")!)
    ]

    func viewController(for index: Int) -> UIViewController {
        switch index {
        case 0:
            return UINavigationController(rootViewController: PendingCapsulesViewController())
        case 1:
            return UINavigationController(rootViewController: CreateCapsulesViewController())
        case 2:
            return UINavigationController(rootViewController: OpenedCapsulesViewController())
        case 3:
            return UINavigationController(rootViewController: ProfileViewController())
        default:
            fatalError("Invalid tab index")
        }
    }
}
