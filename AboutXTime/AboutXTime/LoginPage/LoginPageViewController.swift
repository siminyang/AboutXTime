//
//  LoginPageViewController.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/26.
//

import UIKit
import AuthenticationServices
import FirebaseAuth
import CryptoKit
import AVKit

class LoginViewController: UIViewController {

    fileprivate var currentNonce: String?
    var onLoginSuccess: (() -> Void)?
    private var player: AVPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        setupVideoBackground()

        let keychainSuccess =
        KeychainManager.standard.delete(service: "com.aboutXTime.service", account: "appleUserIdentifier")
        if keychainSuccess {
            print("Successfully removed userIdentifier from Keychain.")
        } else {
            print("Failed to remove userIdentifier from Keychain or it did not exist.")
        }

        setupAppleSignInButton()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupVideoBackground() {
        guard let videoPath = Bundle.main.path(forResource: "blackhole2", ofType: "mov") else {
            print("Failed to find the video file.")
            return
        }

        let videoURL = URL(fileURLWithPath: videoPath)
        player = AVPlayer(url: videoURL)
        let playerLayer = AVPlayerLayer(player: player)

        playerLayer.frame = view.bounds
        playerLayer.videoGravity = .resizeAspectFill

        view.layer.insertSublayer(playerLayer, at: 0)

        player?.play()
    }

    // MARK: - 設置 Apple Sign-In 按鈕
    private func setupAppleSignInButton() {
        let appleSignInButton = ASAuthorizationAppleIDButton()

        let buttonWidth: CGFloat = 250
        let buttonHeight: CGFloat = 50
        appleSignInButton.frame = CGRect(x: (view.bounds.width - buttonWidth) / 2,
                                         y: (view.bounds.height - buttonHeight) / 2,
                                         width: buttonWidth,
                                         height: buttonHeight)

        appleSignInButton.layer.borderColor = STColor.CC1.uiColor.cgColor
        appleSignInButton.layer.borderWidth = 0.5
        appleSignInButton.layer.cornerRadius = 20

        appleSignInButton.addTarget(self, action: #selector(handleAppleSignIn), for: .touchUpInside)
        appleSignInButton.center = view.center
        view.addSubview(appleSignInButton)
    }

    // MARK: - 生成隨機 nonce
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      var randomBytes = [UInt8](repeating: 0, count: length)
      let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
      if errorCode != errSecSuccess {
        fatalError(
          "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
        )
      }

      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

      let nonce = randomBytes.map { byte in
        charset[Int(byte) % charset.count]
      }

      return String(nonce)
    }

    // MARK: - 將 nonce 進行 SHA256 哈希
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }

    // MARK: - Apple Sign-In 處理
    @objc private func handleAppleSignIn() {
        let nonce = randomNonceString()
          currentNonce = nonce
          let appleIDProvider = ASAuthorizationAppleIDProvider()
          let request = appleIDProvider.createRequest()
          request.requestedScopes = [.fullName, .email]
          request.nonce = sha256(nonce)

          let authorizationController = ASAuthorizationController(authorizationRequests: [request])
          authorizationController.delegate = self
          authorizationController.presentationContextProvider = self
          authorizationController.performRequests()
    }

    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            saveUserIdentifierToKeychain(userIdentifier)

            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }

            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }

            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }

            let credential = OAuthProvider.appleCredential(
                withIDToken: idTokenString,
                rawNonce: nonce,
                fullName: appleIDCredential.fullName
            )

            let fullName = getFullName(from: appleIDCredential)
            UserDefaults.standard.set(fullName, forKey: "userFullName")

            signInWithApple(credential: credential, fullName: fullName, userIdentifier: userIdentifier)
        }
    }

    private func saveUserIdentifierToKeychain(_ userIdentifier: String) {
        if let userData = userIdentifier.data(using: .utf8) {
            let success =
            KeychainManager.standard.save(userData, service: "com.aboutXTime.service",
                                          account: "appleUserIdentifier")
            print(success ? 
                  "Successfully saved userIdentifier to Keychain." : "Failed to save userIdentifier to Keychain.")
        }
    }

    private func getFullName(from credential: ASAuthorizationAppleIDCredential) -> String {
        let defaultName = "User"
        if let givenName = credential.fullName?.givenName, let familyName = credential.fullName?.familyName {
            return "\(givenName) \(familyName)".trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            return defaultName
        }
    }

    private func signInWithApple(credential: OAuthCredential, fullName: String, userIdentifier: String) {
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print("Firebase Sign In with Apple failed: \(error)")
                return
            }

            guard let uid = authResult?.user.uid else { return }
            UserDefaults.standard.set(uid, forKey: "userUID")
            print("UID has been saved to UserDefaults: \(uid)")

            let email = authResult?.user.email ?? "No Email"
            let name = fullName.isEmpty ? (authResult?.user.displayName ?? "User") : fullName

            self.checkIfUserExistsInFirestore(uid: uid, email: email, name: name, userIdentifier: userIdentifier)
        }
    }

    private func checkIfUserExistsInFirestore(uid: String, email: String, name: String, userIdentifier: String) {
        let userRef = FirebaseManager.shared.firestore.collection(Constant.users).document(uid)
        userRef.getDocument { (document, error) in
            if let error = error {
                print("Error fetching user data: \(error)")
                return
            }

            if let document = document, document.exists, let data = document.data() {
                self.loadExistingUserData(document: data, uid: uid, userIdentifier: userIdentifier)
            } else {
                self.createNewUser(uid: uid, email: email, name: name, userIdentifier: userIdentifier)
            }

            self.onLoginSuccess?()
            self.dismiss(animated: true, completion: nil)
        }
    }

    private func loadExistingUserData(document: [String: Any], uid: String, userIdentifier: String) {
        let existingName = document["name"] as? String ?? "User"
        let existingEmail = document["email"] as? String ?? "No Email"
        let existingAvatarUrl = document["avatarUrl"] as? String ?? ""
        let existingCreatedCapsulesIds = document["createdCapsulesIds"] as? [String] ?? []
        let existingReceivedCapsulesIds = document["receivedCapsulesIds"] as? [String] ?? []
        let existingSharedCapsulesIds = document["sharedCapsulesIds"] as? [String] ?? []
        let existingFriends = document["friends"] as? [Friend] ?? []

        UserDefaults.standard.set(existingName, forKey: "userFullName")

        let user = User(
            id: uid,
            email: existingEmail,
            name: existingName,
            avatarUrl: existingAvatarUrl,
            createdCapsulesIds: existingCreatedCapsulesIds,
            receivedCapsulesIds: existingReceivedCapsulesIds,
            sharedCapsulesIds: existingSharedCapsulesIds,
            friends: existingFriends,
            userIdentifier: userIdentifier
        )

        print("Loaded existing user data from Firestore: \(user)")
    }

    private func createNewUser(uid: String, email: String, name: String, userIdentifier: String) {
        let user = User(
            id: uid,
            email: email,
            name: name,
            avatarUrl: "",
            createdCapsulesIds: [],
            receivedCapsulesIds: [],
            sharedCapsulesIds: [],
            friends: [],
            userIdentifier: userIdentifier
        )

        saveUserToFirestore(user: user)
    }

    // MARK: - Save user to Firestore
    private func saveUserToFirestore(user: User) {
        FirebaseManager.shared.saveUserToFirestore(user: user)
    }

    // MARK: - Apple Sign-In 錯誤處理
    internal func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Apple failed: \(error)")
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate,
                               ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window ?? UIWindow()
    }
}
