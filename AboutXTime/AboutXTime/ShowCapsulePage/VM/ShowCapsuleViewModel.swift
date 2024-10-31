//
//  ShowCapsuleViewModel.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/17.
//

import SwiftUI
import AVKit
import Firebase

class CapsuleViewModel: ObservableObject {
    @Published var replyMessages: [ReplyMessage]
    @Published var replyText: String = ""
    @Published var showReplySection: Bool = false
    @Published var scrollViewHeight: CGFloat = 0

    private var capsule: Capsule
    private var listener: ListenerRegistration?
    private let userId = UserDefaults.standard.string(forKey: "userUID")
    var capsuleInfo: Capsule {
        capsule
    }

    init(capsule: Capsule) {
        self.capsule = capsule
        self.replyMessages = capsule.replyMessages ?? []
    }

    deinit {
        stopListening()
    }

    func updateCapsuleStatus() {
        FirebaseManager.shared.updateCapsuleStatus(capsuleId: capsule.capsuleId, status: 1) { result in
            switch result {
            case .success:
                print("膠囊狀態更新成功")
            case .failure(let error):
                print("膠囊狀態更新失敗: \(error.localizedDescription)")
            }
        }
    }

    func startListening() {
        listener = FirebaseManager.shared.addCapsuleListener(capsuleId: capsule.capsuleId) { [weak self] result in
            DispatchQueue.main.async {
                self?.handleCapsuleUpdate(result: result)
            }
        }
    }

    private func handleCapsuleUpdate(result: Result<Capsule, Error>) {
        switch result {
        case .success(let updatedCapsule):
            self.updateCapsuleData(updatedCapsule)
        case .failure(let error):
            print("Failed to listen for capsule updates: \(error.localizedDescription)")
        }
    }

    private func updateCapsuleData(_ updatedCapsule: Capsule) {
        self.capsule = updatedCapsule
        self.replyMessages = updatedCapsule.replyMessages ?? []
        for reply in self.replyMessages {
            fetchOrGetFriend(for: reply)
        }
    }

    private func fetchOrGetFriend(for reply: ReplyMessage) {
        FirebaseManager.shared.fetchFriendData(currentUserId: self.userId ?? "", friendId: reply.userId) { result in
            switch result {
            case .success(let friend):
                print("Fetched friend data: \(friend.id)")
            case .failure(let error):
                print("Failed to fetch friend data: \(error.localizedDescription)")
            }
        }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }

    func addReply() {
        guard !replyText.isEmpty else { return }

        guard let userId = UserDefaults.standard.string(forKey: "userUID") else {
            print("Failed to get UID from UserDefaults.")
            return
        }

        let newReply = ReplyMessage(userId: userId, text: replyText, createdTime: Date(), id: UUID().uuidString)
        replyMessages.append(newReply)
        replyText = ""

        FirebaseManager.shared.addReplyToCapsule(capsuleId: capsule.capsuleId, reply: newReply) { result in
            switch result {
            case .success:
                print("Reply saved successfully")
            case .failure(let error):
                print("Failed to save reply: \(error.localizedDescription)")
            }
        }
    }
}
