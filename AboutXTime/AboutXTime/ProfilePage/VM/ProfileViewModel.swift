//
//  ProfileViewModel.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/28.
//

import Foundation
import SwiftUI
import FirebaseFirestore

class ProfileViewModel: ObservableObject {
    @Published var userFullName: String = "User"
    @Published var userAvatar: String = "planet4"
    @Published var userID: String = ""
    @Published var friends: [Friend] = []
    @Published var alertType: AlertType?
    @Published var isShowingCopyAlert = false

    private let database = Firestore.firestore()
    private var userIDFromFirestore: String
    private let avatarKey = "userAvatar"
    private var listener: ListenerRegistration?

    enum AlertType: Identifiable {
        case report, block, delete, reportConfirmation, blockConfirmation, deleteConfirmation, error
        var id: Self { self }
    }

    init(userID: String) {
        self.userIDFromFirestore = userID
        fetchUserData()
        setupUserAvatar()
        startListeningForUserChanges()
    }

    deinit {
        listener?.remove()
    }

    private func setupUserAvatar() {
        FirebaseManager.shared.fetchDocument(collection: Constant.users,
                                             documentID: userIDFromFirestore) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let document):
                if let avatarUrl = document.data()?["avatarUrl"] as? String, !avatarUrl.isEmpty {
                    self.userAvatar = avatarUrl
                    UserDefaults.standard.set(avatarUrl, forKey: self.avatarKey)
                } else {
                    self.setRandomAvatar()
                }
            case .failure(let error):
                print("Error fetching avatarUrl: \(error.localizedDescription)")
                self.setRandomAvatar()
            }
        }
    }

    private func setRandomAvatar() {
        let randomAvatar = "planet\(Int.random(in: 1...18))"
        self.userAvatar = randomAvatar
        UserDefaults.standard.set(randomAvatar, forKey: self.avatarKey)
        updateUserAvatarInFirestore(avatar: randomAvatar)
    }

    private func startListeningForUserChanges() {
        let userRef = database.collection(Constant.users).document(userIDFromFirestore)
        listener = userRef.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                print("Error listening for user changes: \(error.localizedDescription)")
                return
            }

            guard let data = snapshot?.data() else {
                print("No user data found or invalid format.")
                return
            }

            DispatchQueue.main.async {
                self.userFullName = data["name"] as? String ?? "User"
                self.userAvatar = data["avatarUrl"] as? String ?? self.userAvatar

                if let friendsArray = data["friends"] as? [[String: Any]] {
                    self.friends = friendsArray.compactMap { Friend(dictionary: $0) }
                    self.fetchNamesForEmptyFriends()
                    self.friends.sort { $0.latestInteractionDate > $1.latestInteractionDate }
                }
            }
        }
    }

    func fetchUserData() {
        FirebaseManager.shared.fetchDocument(
            collection: Constant.users,
            documentID: userIDFromFirestore) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let document):
                    let data = document.data()
                    DispatchQueue.main.async {
                        self.userFullName = data?["name"] as? String ?? "User"
                        self.userID = self.userIDFromFirestore
                    }

                    if let friendsArray = data?["friends"] as? [[String: Any]] {
                        self.friends = friendsArray.compactMap { Friend(dictionary: $0) }
                        self.fetchNamesForEmptyFriends()
                        self.friends.sort { $0.latestInteractionDate > $1.latestInteractionDate }
                    }
                case .failure(let error):
                    print("Error fetching user data: \(error.localizedDescription)")
                }
            }
    }

    func showCopyNotification() {
        withAnimation {
            isShowingCopyAlert = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            withAnimation {
                self.isShowingCopyAlert = false
            }
        }
    }

    // 查找朋友的名字
    private func fetchNamesForEmptyFriends() {
        for (index, friend) in friends.enumerated()
        where friend.fullName.isEmpty {
            fetchFriendName(friendID: friend.id) { [weak self] name in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.friends[index].fullName = name
                    self.updateFriendsInFirestore()
                }
            }
        }
    }

    private func fetchFriendName(friendID: String, completion: @escaping (String) -> Void) {
        FirebaseManager.shared.fetchDocument(collection: Constant.users, documentID: friendID) { result in
            switch result {
            case .success(let document):
                let name = document.data()?["name"] as? String ?? "Unknown"
                completion(name)
            case .failure:
                completion("Unknown")
            }
        }
    }
}

// MARK: - 更改頭像或名稱方法
extension ProfileViewModel {
    private func updateUserAvatarInFirestore(avatar: String) {
        FirebaseManager.shared.saveData(collection: Constant.users,
                                        documentID: userIDFromFirestore,
                                        data: ["avatarUrl": avatar]) { error in
            if let error = error {
                print("Error updating avatar in Firestore: \(error.localizedDescription)")
            }
        }
    }

    private func updateFriendsInFirestore() {
        let friendsData = friends.map { $0.toDictionary() }
        FirebaseManager.shared.saveData(collection: Constant.users,
                                        documentID: userIDFromFirestore,
                                        data: ["friends": friendsData]) { error in
            if let error = error {
                print("Error updating friends in Firestore: \(error.localizedDescription)")
            }
        }
    }

    func changeUserAvatar() {
        let newAvatar = "planet\(Int.random(in: 1...18))"
        self.userAvatar = newAvatar
        UserDefaults.standard.set(newAvatar, forKey: avatarKey)
        updateUserAvatarInFirestore(avatar: newAvatar)
    }

    func changeFriendAvatar(friendID: String) {
        guard let index = friends.firstIndex(where: { $0.id == friendID }) else { return }

        let newAvatar = "planet\(Int.random(in: 1...18))"
        friends[index].avatar = newAvatar
        updateFriendsInFirestore()
    }

    func updateFriendName(friendID: String, newName: String) {
        guard let index = friends.firstIndex(where: { $0.id == friendID }) else { return }
        friends[index].fullName = newName
        updateFriendsInFirestore()
    }
}

// MARK: - 舉報方法
extension ProfileViewModel {
    func reportFriend(friendId: String) {
        print("Reporting friend with ID: \(friendId)")

        FirebaseManager.shared.deleteFriendId(userId: userID, friendId: friendId) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.alertType = .reportConfirmation
                case .failure:
                    self.alertType = .error
                }
            }
        }
    }

    func blockFriend(friendId: String) {
        print("blocking friend with ID: \(friendId)")

        FirebaseManager.shared.deleteFriendId(userId: userID, friendId: friendId) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.alertType = .blockConfirmation
                case .failure:
                    self.alertType = .error
                }
            }
        }
    }

    func deleteFriend(friendId: String) {
        print("deleting friend with ID: \(friendId)")

        FirebaseManager.shared.deleteFriendId(userId: userID, friendId: friendId) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Friend successfully deleted.")
                    self.alertType = .deleteConfirmation
                case .failure:
                    print("Failed to delete friend with error")
                    self.alertType = .error
                }
            }
        }
    }
}
