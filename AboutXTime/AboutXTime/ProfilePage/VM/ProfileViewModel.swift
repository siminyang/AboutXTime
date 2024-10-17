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
    @Published var showReportConfirmation: Bool = false
    @Published var showBlockConfirmation: Bool = false
    @Published var showDeleteConfirmation: Bool = false
    @Published var showErrorAlert: Bool = false

    private let database = Firestore.firestore()
    private var userIDFromFirestore: String
    private let avatarKey = "userAvatar"
    private var listener: ListenerRegistration?

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
        let userRef = database.collection("users").document(userIDFromFirestore)
        userRef.getDocument { [weak self] document, error in
            guard let self = self else { return }

            if let error = error {
                print("Error fetching avatarUrl: \(error.localizedDescription)")
                return
            }

            if let avatarUrl = document?.data()?["avatarUrl"] as? String, !avatarUrl.isEmpty {
                self.userAvatar = avatarUrl
                UserDefaults.standard.set(avatarUrl, forKey: self.avatarKey)
            } else {
                let randomAvatar = "planet\(Int.random(in: 1...18))"
                self.userAvatar = randomAvatar
                UserDefaults.standard.set(randomAvatar, forKey: self.avatarKey)
                self.updateUserAvatarInFirestore(avatar: randomAvatar)
            }
        }
    }

    private func startListeningForUserChanges() {
        let userRef = database.collection("users").document(userIDFromFirestore)
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
                if let avatarUrl = data["avatarUrl"] as? String {
                    self.userAvatar = avatarUrl
                }

                self.userFullName = data["name"] as? String ?? "User"
                UserDefaults.standard.set(self.userFullName, forKey: "userFullName")

                if let friendsArray = data["friends"] as? [[String: Any]] {
                    self.friends = friendsArray.compactMap { friendData in
                        let id = friendData["id"] as? String ?? ""
                        let fullName = friendData["fullName"] as? String ?? ""
                        let timestamp = (friendData["latestInteractionDate"] as? Timestamp)?.dateValue() ?? Date()
                        let avatar = friendData["avatar"] as? String ?? "planet\(Int.random(in: 1...18))"

                        let friend = Friend(id: id,
                                            fullName: fullName,
                                            avatar: avatar,
                                            latestInteractionDate: timestamp)

                        FriendsCacheManager.shared.cacheFriend(friend)

                        return friend
                    }
                    self.fetchNamesForEmptyFriends()
                    self.friends.sort { $0.latestInteractionDate > $1.latestInteractionDate }

                } else {
                    print("No friends found for the user.")
                }
            }
        }
    }

    func fetchUserData() {
        print("Fetching data for userID: \(userIDFromFirestore)")

        let userRef = database.collection("users").document(userIDFromFirestore)

        userRef.getDocument { [weak self] document, error in
            guard let self = self else { return }

            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }

            guard let document = document, document.exists, let data = document.data() else {
                print("User document does not exist or data is empty")
                return
            }

            DispatchQueue.main.async {
                self.userFullName = data["name"] as? String ?? "User"
                UserDefaults.standard.set(self.userFullName, forKey: "userFullName")
                self.userID = self.userIDFromFirestore

                if let friendsArray = data["friends"] as? [[String: Any]] {
                    self.friends = friendsArray.compactMap { friendData in
                        let id = friendData["id"] as? String ?? ""
                        let fullName = friendData["fullName"] as? String ?? ""
                        let timestamp =
                        (friendData["latestInteractionDate"] as? Timestamp)?.dateValue() ?? Date()
                        let avatar = friendData["avatar"] as? String ?? "planet\(Int.random(in: 1...18))"

                        let friend = Friend(id: id,
                                            fullName: fullName,
                                            avatar: avatar,
                                            latestInteractionDate: timestamp)

                        FriendsCacheManager.shared.cacheFriend(friend)

                        return friend
                    }

                    self.fetchNamesForEmptyFriends()

                    self.friends.sort { $0.latestInteractionDate > $1.latestInteractionDate }
                } else {
                    print("No friends found for the user.")
                }
            }
        }
    }

    // 查找朋友的名字
    private func fetchNamesForEmptyFriends() {
        for (index, friend) in friends.enumerated() {
            if friend.fullName.isEmpty {
                fetchFriendName(friendID: friend.id) { [weak self] name in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        self.friends[index].fullName = name
                        self.updateFriendsInFirestore()
                    }
                }
            }
        }
    }

    private func fetchFriendName(friendID: String, completion: @escaping (String) -> Void) {
        let friendRef = database.collection("users").document(friendID)
        friendRef.getDocument { document, error in
            if let error = error {
                print("Error fetching friend's name: \(error.localizedDescription)")
                completion("Unknown")
                return
            }

            if let name = document?.data()?["name"] as? String {
                completion(name)
            } else {
                completion("Unknown")
            }
        }
    }

    // MARK: 更改頭像或名稱方法
    private func updateUserAvatarInFirestore(avatar: String) {
        let userRef = database.collection("users").document(userIDFromFirestore)
        userRef.updateData(["avatarUrl": avatar]) { error in
            if let error = error {
                print("Error updating avatar in Firestore: \(error.localizedDescription)")
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

    private func updateFriendsInFirestore() {
        let userRef = database.collection("users").document(userIDFromFirestore)
        userRef.updateData([
            "friends": friends.map { $0.toDictionary() }
        ]) { error in
            if let error = error {
                print("Error updating friends in Firestore: \(error.localizedDescription)")
            }
        }
    }

    // MARK: 舉報方法
    func reportFriend(friendId: String) {
        print("Reporting friend with ID: \(friendId)")

        FirebaseManager.shared.deleteFriendId(userId: userID, friendId: friendId) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.showReportConfirmation = true
                }
            case .failure:
                DispatchQueue.main.async {
                    self.showErrorAlert = true
                }
            }
        }
    }

    func blockFriend(friendId: String) {
        print("blocking friend with ID: \(friendId)")

        FirebaseManager.shared.deleteFriendId(userId: userID, friendId: friendId) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.showBlockConfirmation = true
                }
            case .failure:
                DispatchQueue.main.async {
                    self.showErrorAlert = true
                }
            }
        }
    }

    func deleteFriend(friendId: String) {
        print("deleting friend with ID: \(friendId)")

        FirebaseManager.shared.deleteFriendId(userId: userID, friendId: friendId) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.showDeleteConfirmation = true
                }
            case .failure:
                DispatchQueue.main.async {
                    self.showErrorAlert = true
                }
            }
        }
    }
}
