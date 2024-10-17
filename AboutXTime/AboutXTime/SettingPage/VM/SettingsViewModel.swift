//
//  SettingsViewModel.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/29.
//

import Foundation
import FirebaseAuth
import AuthenticationServices
import CryptoKit
import UIKit
import SwiftUI

class SettingsViewModel: NSObject, ObservableObject {
    @Published var isProcessing = false
    @Published var showLogoutAlert = false
    @Published var showDeleteAlert = false

    var onLogout: (() -> Void)?
    var onDeleteAccount: (() -> Void)?
    var onError: ((String) -> Void)?

    private var currentNonce: String?

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("UserDidLogout"), object: nil)
    }

    func logout() {
        do {
            try Auth.auth().signOut()
            NotificationCenter.default.post(name: NSNotification.Name("UserDidLogout"), object: nil)
            onLogout?()
        } catch let error {
            onError?(error.localizedDescription)
        }
    }

    func deleteAccount() {
        let nonce = CryptoUtils.randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = CryptoUtils.sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

extension SettingsViewModel: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    // 授權成功後的處理
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {

        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            onError?("無法取得 AppleID 憑證")
            return
        }

        guard currentNonce != nil else {
            onError?("無效狀態：接收到登入回調，但沒有發送登入請求。")
            return
        }

        guard let appleAuthCode = appleIDCredential.authorizationCode else {
            onError?("無法獲取授權碼")
            return
        }

        guard let authCodeString = String(data: appleAuthCode, encoding: .utf8) else {
            onError?("無法將授權碼資料序列化為字串: \(appleAuthCode.debugDescription)")
            return
        }

        Task {
            do {
                try await Auth.auth().revokeToken(withAuthorizationCode: authCodeString)
                try await Auth.auth().currentUser?.delete()

                NotificationCenter.default.post(name: NSNotification.Name("UserDidLogout"), object: nil)

                onDeleteAccount?()
            } catch {
                onError?(error.localizedDescription)
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        onError?(error.localizedDescription)
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        let windowScene = UIApplication.shared.connectedScenes
            .first { $0.activationState == .foregroundActive } as? UIWindowScene

        return windowScene?.windows.first { $0.isKeyWindow } ?? UIWindow()
    }
}
