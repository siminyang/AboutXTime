//
//  UserModel.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/12.
//

import Foundation
import FirebaseCore

// MARK: - User

struct User {
    let id: String
    let email: String?
    let name: String?
    let avatarUrl: String?
    let createdCapsulesIds: [String]?
    let receivedCapsulesIds: [String]?
    let sharedCapsulesIds: [String]?
    let friends: [Friend]?
    let userIdentifier: String?

    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "email": email ?? "No Email",
            "name": name ?? "Unknown",
            "avatarUrl": avatarUrl ?? "",
            "createdCapsulesIds": createdCapsulesIds ?? [],
            "receivedCapsulesIds": receivedCapsulesIds ?? [],
            "sharedCapsulesIds": sharedCapsulesIds ?? [],
            "userIdentifier": userIdentifier ?? ""
        ]

        if let friends = friends {
            dict["friends"] = friends.map { $0.toDictionary() }
        }

        return dict
    }
}

struct Friend: Identifiable {
    var id: String
    var fullName: String
    var avatar: String
    var latestInteractionDate: Date

    init(id: String, fullName: String, avatar: String, latestInteractionDate: Date) {
        self.id = id
        self.fullName = fullName
        self.avatar = avatar
        self.latestInteractionDate = latestInteractionDate
    }

    init?(dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
              let fullName = dictionary["fullName"] as? String,
              let avatar = dictionary["avatar"] as? String,
              let timestamp = dictionary["latestInteractionDate"] as? Timestamp else {
            return nil
        }

        self.id = id
        self.fullName = fullName
        self.avatar = avatar
        self.latestInteractionDate = timestamp.dateValue()
    }

    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "fullName": fullName,
            "avatar": avatar,
            "latestInteractionDate": Timestamp(date: latestInteractionDate)
        ]
    }
}

class FriendWrapper {
    let friend: Friend

    init(friend: Friend) {
        self.friend = friend
    }
}
