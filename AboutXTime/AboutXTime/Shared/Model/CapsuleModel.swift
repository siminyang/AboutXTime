//
//  CapsuleModel.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/12.
//

import Foundation

struct Capsule: Codable, Identifiable {

    let id: String
    let capsuleId: String
    let creatorId: String
    let recipients: [Recipient]
    let content: [Content]
    let emotionTagLabels: [String]?
    let imageTagLabels: [Int]?
    let createdDate: Date
    let openDate: Date
    let location: Location?
    let isAnonymous: Bool
    let isLocationLocked: Bool
    let isShared: Bool
    let replyMessages: [ReplyMessage]?

    init(
        capsuleId: String,
        creatorId: String,
        recipients: [Recipient],
        content: [Content],
        emotionTagLabels: [String]?,
        imageTagLabels: [Int]?,
        createdDate: Date,
        openDate: Date,
        location: Location?,
        isAnonymous: Bool,
        isLocationLocked: Bool,
        isShared: Bool,
        replyMessages: [ReplyMessage]?
    ) {
        self.capsuleId = capsuleId
        self.creatorId = creatorId
        self.recipients = recipients
        self.content = content
        self.emotionTagLabels = emotionTagLabels
        self.imageTagLabels = imageTagLabels
        self.createdDate = createdDate
        self.openDate = openDate
        self.location = location
        self.isAnonymous = isAnonymous
        self.isLocationLocked = isLocationLocked
        self.isShared = isShared
        self.replyMessages = replyMessages
        self.id = capsuleId
    }
}

struct Recipient: Codable {
    let id: String
    let status: Int
}

struct Content: Codable {
    let imgUrl: String?
    let text: String
    let audioUrl: String?
    let videoUrl: String?
    let userId: String

    let fromWhom: String
    let toWhom: String
}

struct Location: Codable {
    let latitude: Double?
    let longitude: Double?
    let radius: Int?
}

struct ReplyMessage: Codable, Identifiable, Equatable {
    let userId: String
    let text: String
    let createdTime: Date
    let id: String

    static func == (lhs: ReplyMessage, rhs: ReplyMessage) -> Bool {
        return lhs.id == rhs.id &&
        lhs.userId == rhs.userId &&
        lhs.text == rhs.text &&
        lhs.createdTime == rhs.createdTime
    }
}

struct CapsuleUpdateInfo {
    let content: Content
    let openDate: Date
    let location: Location?
    let isAnonymous: Bool
    let isLocationLocked: Bool
    let isShared: Bool
    let recipient: String
    let emotionTagLabels: [String]?
}
