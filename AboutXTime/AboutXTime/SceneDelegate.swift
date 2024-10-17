//
//  SceneDelegate.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/12.
//

import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleLogout),
                                               name: NSNotification.Name("UserDidLogout"),
                                               object: nil)

        setRootViewController()
    }

    @objc private func handleLogout() {
        DispatchQueue.main.async {
            self.window?.rootViewController?.dismiss(animated: false, completion: {
                self.setRootViewController()
            })
        }
    }

    private func setRootViewController() {
        let tabBarViewModel = TabBarViewModel()

        if isUserLoggedIn() {
            let tabBarController = TabBarController(viewModel: tabBarViewModel)
            self.window?.rootViewController = tabBarController
        } else {
            let loginVC = LoginViewController()

            loginVC.onLoginSuccess = { [weak self] in
                self?.showOnboardingIfNeeded {
                    let tabBarController = TabBarController(viewModel: tabBarViewModel)
                    self?.window?.rootViewController = tabBarController
                }
            }

            window?.rootViewController = loginVC
        }

        window?.makeKeyAndVisible()
    }

    private func showOnboardingIfNeeded(completion: @escaping () -> Void) {
        let onboardingVC = OnboardingViewController()
        onboardingVC.onOnboardingComplete = {
            completion()
        }
        window?.rootViewController = onboardingVC
    }

    private func isUserLoggedIn() -> Bool {
        if let currentUser = Auth.auth().currentUser,
           KeychainManager.standard.get(service: "com.aboutXTime.service", account: "appleUserIdentifier") != nil {

            return currentUser.uid == UserDefaults.standard.string(forKey: "userUID")
        }

        clearUserSession()
        return false
    }

    private func clearUserSession() {
        try? Auth.auth().signOut()

//        KeychainManager.standard.delete(service: "com.aboutXTime.service", account: "appleUserIdentifier")

        UserDefaults.standard.removeObject(forKey: "userUID")
        UserDefaults.standard.removeObject(forKey: "userFullName")
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}
