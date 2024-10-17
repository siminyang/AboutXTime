//
//  FirebaseManager.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/12.
//

import Firebase
import FirebaseFirestore
import FirebaseStorage

class FirebaseManager {
    static let shared = FirebaseManager()
    let firestore = Firestore.firestore()
    private let storage = Storage.storage()
    private init() {}
}

// MARK: - Capsule fetching Operations
extension FirebaseManager {
    func checkCapsuleExists(capsuleId: String, completion: @escaping (Bool) -> Void) {
        let capsuleRef = firestore.collection(Constant.capsules).document(capsuleId)
        capsuleRef.getDocument { (document, _) in
            if let document = document, document.exists {
                completion(true)
            } else {
                completion(false)
            }
        }
    }

    @discardableResult
    func fetchUserCapsules(userId: String, completion: @escaping (Result<[Capsule], Error>) -> Void) -> ListenerRegistration {
        print("正在獲取 userId 為 \(userId) 的膠囊")

        let query = firestore.collection(Constant.capsules)

        let listener = query.addSnapshotListener { (snapshot, error) in
            if let error = error {
                print("Firestore 監聽錯誤: \(error)")
                completion(.failure(error))
                return
            }

            guard let documents = snapshot?.documents else {
                print("未找到文件")
                completion(.success([]))
                return
            }

            print("獲取到 \(documents.count) 個文件")

            let capsules = documents.compactMap { document -> Capsule? in
                let data = document.data()

                guard let capsuleId = data["capsuleId"] as? String,
                      let creatorId = data["creatorId"] as? String,
                      let createdDateTimestamp = data["createdDate"] as? Timestamp,
                      let openDateTimestamp = data["openDate"] as? Timestamp,
                      let isAnonymous = data["isAnonymous"] as? Bool,
                      let isLocationLocked = data["isLocationLocked"] as? Bool,
                      let isShared = data["isShared"] as? Bool else {
                    print("無法解析基本欄位 for document \(document.documentID)")
                    return nil
                }

                guard let recipientsDict = data["recipients"] as? [String: [String: Any]],
                      let recipientData = recipientsDict[userId],
                      let status = recipientData["status"] as? Int else {
                    print("無法找到 recipients 中的 \(userId) 或者無法解析")
                    return nil
                }

                let recipients = [Recipient(id: userId, status: status)]

                let content = (data["content"] as? [String: [String: Any]])?.compactMap { (contentUserId, contentData) -> Content? in
                    guard let text = contentData["text"] as? String else { return nil }
                    return Content(imgUrl: contentData["imgUrl"] as? String,
                                   text: text,
                                   audioUrl: contentData["audioUrl"] as? String,
                                   videoUrl: contentData["videoUrl"] as? String,
                                   userId: contentUserId,
                                   fromWhom: contentData["fromWhom"] as? String ?? "",
                                   toWhom: contentData["toWhom"] as? String ?? "")
                } ?? []

                let emotionTagLabels = data["emotionTagLabels"] as? [String]
                let imageTagLabels = data["imageTagLabels"] as? [Int]

                let location: Location?
                if let locationData = data["location"] as? [String: Any],
                   let geoPoint = locationData["LatitudeAndLongitude"] as? GeoPoint {
                    location = Location(latitude: geoPoint.latitude,
                                        longitude: geoPoint.longitude,
                                        radius: locationData["radius"] as? Int ?? 0)
                } else {
                    location = nil
                }

                let replyMessages: [ReplyMessage] = (data["replyMessages"] as? [[String: Any]])?.compactMap { replyData in
                    guard let replyUserId = replyData["userId"] as? String,
                          let replyText = replyData["text"] as? String,
                          let replyCreatedTimeTimestamp = replyData["createdTime"] as? Timestamp,
                          let replyId = replyData["id"] as? String else {
                        return nil
                    }
                    return ReplyMessage(userId: replyUserId,
                                        text: replyText,
                                        createdTime: replyCreatedTimeTimestamp.dateValue(),
                                        id: replyId)
                } ?? []

                return Capsule(capsuleId: capsuleId,
                               creatorId: creatorId,
                               recipients: recipients,
                               content: content,
                               emotionTagLabels: emotionTagLabels,
                               imageTagLabels: imageTagLabels,
                               createdDate: createdDateTimestamp.dateValue(),
                               openDate: openDateTimestamp.dateValue(),
                               location: location,
                               isAnonymous: isAnonymous,
                               isLocationLocked: isLocationLocked,
                               isShared: isShared,
                               replyMessages: replyMessages)
            }

            print("成功解析的膠囊數量: \(capsules.count)")
            completion(.success(capsules))
        }
        return listener
    }

    // 指定的單顆膠囊
    func addCapsuleListener(capsuleId: String, completion: @escaping (Result<Capsule, Error>) -> Void) -> ListenerRegistration {
        let capsuleRef = firestore.collection(Constant.capsules).document(capsuleId)
        let listener = capsuleRef.addSnapshotListener { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = snapshot?.data() else {
                print("No data found for document: \(capsuleId)")
                return
            }

            guard let creatorId = data["creatorId"] as? String,
                  let createdDateTimestamp = data["createdDate"] as? Timestamp,
                  let openDateTimestamp = data["openDate"] as? Timestamp,
                  let isAnonymous = data["isAnonymous"] as? Bool,
                  let isLocationLocked = data["isLocationLocked"] as? Bool,
                  let isShared = data["isShared"] as? Bool else {
                print("Unable to parse essential fields for document \(capsuleId)")
                return
            }

            guard let recipientsDict = data["recipients"] as? [String: [String: Any]] else {
                print("Unable to find or parse recipients for document \(capsuleId)")
                return
            }

            let recipients = recipientsDict.compactMap { (key, value) -> Recipient? in
                guard let status = value["status"] as? Int else { return nil }
                return Recipient(id: key, status: status)
            }

            let content = (data["content"] as? [String: [String: Any]])?.compactMap { (contentUserId, contentData) -> Content? in
                guard let text = contentData["text"] as? String else { return nil }
                return Content(
                    imgUrl: contentData["imgUrl"] as? String,
                    text: text,
                    audioUrl: contentData["audioUrl"] as? String,
                    videoUrl: contentData["videoUrl"] as? String,
                    userId: contentUserId,
                    fromWhom: contentData["fromWhom"] as? String ?? "",
                    toWhom: contentData["toWhom"] as? String ?? ""
                )
            } ?? []

            let emotionTagLabels = data["emotionTagLabels"] as? [String]
            let imageTagLabels = data["imageTagLabels"] as? [Int]

            let location: Location?
            if let locationData = data["location"] as? [String: Any],
               let geoPoint = locationData["LatitudeAndLongitude"] as? GeoPoint {
                location = Location(
                    latitude: geoPoint.latitude,
                    longitude: geoPoint.longitude,
                    radius: locationData["radius"] as? Int
                )
            } else {
                location = nil
            }

            let replyMessages: [ReplyMessage] = (data["replyMessages"] as? [[String: Any]])?.compactMap { replyData in
                guard let replyUserId = replyData["userId"] as? String,
                      let replyText = replyData["text"] as? String,
                      let replyCreatedTimeTimestamp = replyData["createdTime"] as? Timestamp,
                      let replyId = replyData["id"] as? String else {
                    return nil
                }
                return ReplyMessage(
                    userId: replyUserId,
                    text: replyText,
                    createdTime: replyCreatedTimeTimestamp.dateValue(),
                    id: replyId
                )
            } ?? []

            let updatedCapsule = Capsule(
                capsuleId: capsuleId,
                creatorId: creatorId,
                recipients: recipients,
                content: content,
                emotionTagLabels: emotionTagLabels,
                imageTagLabels: imageTagLabels,
                createdDate: createdDateTimestamp.dateValue(),
                openDate: openDateTimestamp.dateValue(),
                location: location,
                isAnonymous: isAnonymous,
                isLocationLocked: isLocationLocked,
                isShared: isShared,
                replyMessages: replyMessages
            )

            completion(.success(updatedCapsule))
        }

        return listener
    }
}

// MARK: - Capsule Update Operations
extension FirebaseManager {

    func createCapsule(completion: @escaping (Result<String, Error>) -> Void) {
        let capsuleRef = firestore.collection(Constant.capsules).document()
        let capsuleId = capsuleRef.documentID
        print(">>>>創建時的capId \(capsuleId)")

        guard let creatorId = UserDefaults.standard.string(forKey: "userUID") else {
            print("Failed to get UID from UserDefaults.")
            return
        }

        let capsuleData: [String: Any] = [
            "capsuleId": capsuleId,
            "creatorId": creatorId,
            "recipients": [:],
            "content": [:],
            "createdDate": Timestamp(date: Date())
        ]

        capsuleRef.setData(capsuleData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(capsuleId))
            }
        }
    }

    func updateCapsuleStatus(capsuleId: String, status: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        let capsuleRef = firestore.collection(Constant.capsules).document(capsuleId)

        guard let recipientId = UserDefaults.standard.string(forKey: "userUID") else {
            print("Failed to get UID from UserDefaults.")
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "UID not found"])))
            return
        }

        let recipientData: [String: Any] = [
            "recipients.\(recipientId).status": status
        ]

        capsuleRef.updateData(recipientData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    func addReplyToCapsule(capsuleId: String, reply: ReplyMessage, completion: @escaping (Result<Void, Error>) -> Void) {
        let capsuleRef = firestore.collection(Constant.capsules).document(capsuleId)

        let replyData: [String: Any] = [
            "userId": reply.userId,
            "text": reply.text,
            "createdTime": Timestamp(date: reply.createdTime),
            "id": reply.id
        ]

        capsuleRef.updateData([
            "replyMessages": FieldValue.arrayUnion([replyData])
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    // 更新膠囊內容
    func updateCapsuleContent(capsuleId: String, updateInfo: CapsuleUpdateInfo, imageTagLabels: [Int], completion: @escaping (Result<Void, Error>) -> Void) {
        let capsuleRef = firestore.collection(Constant.capsules).document(capsuleId)

        guard let userId = UserDefaults.standard.string(forKey: "userUID") else {
            completion(.failure(NSError(domain: "UserDefaults Error", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get UID"])))
            return
        }

        let dataToUpdate = prepareCapsuleUpdateData(capsuleId: capsuleId, userId: userId, updateInfo: updateInfo, imageTagLabels: imageTagLabels)

        capsuleRef.updateData(dataToUpdate) { error in
            if let error = error {
                completion(.failure(error))
                return
            }

            self.updateUserCapsuleLists(userId: userId, recipientId: updateInfo.recipient, capsuleId: capsuleId, updateInfo: updateInfo) { result in
                switch result {
                case .success():
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    // 準備要更新的膠囊資料
    private func prepareCapsuleUpdateData(capsuleId: String, userId: String, updateInfo: CapsuleUpdateInfo, imageTagLabels: [Int]) -> [String: Any] {
        var dataToUpdate: [String: Any] = [
            "capsuleId": capsuleId,
            "content.\(userId)": [
                "text": updateInfo.content.text,
                "imgUrl": updateInfo.content.imgUrl ?? "",
                "audioUrl": updateInfo.content.audioUrl ?? "",
                "videoUrl": updateInfo.content.videoUrl ?? "",
                "fromWhom": updateInfo.content.fromWhom,
                "toWhom": updateInfo.content.toWhom
            ],
            "recipients.\(updateInfo.recipient)": ["status": 0],
            "isAnonymous": updateInfo.isAnonymous,
            "isLocationLocked": updateInfo.isLocationLocked,
            "isShared": updateInfo.isShared,
            "openDate": updateInfo.openDate,
            "updatedDate": Date(),
            "imageTagLabels": imageTagLabels,
            "emotionTagLabels": updateInfo.emotionTagLabels as Any
        ]

        if let location = updateInfo.location {
            dataToUpdate["location"] = [
                "LatitudeAndLongitude": GeoPoint(latitude: location.latitude ?? 0.0, longitude: location.longitude ?? 0.0),
                "radius": location.radius ?? 0.0 as Any
            ]
        }

        print(">>>> Data to update: \(dataToUpdate)")

        return dataToUpdate
    }

    // 更新使用者的膠囊列表
    private func updateUserCapsuleLists(userId: String, recipientId: String, capsuleId: String, updateInfo: CapsuleUpdateInfo, completion: @escaping (Result<Void, Error>) -> Void) {
        let userRef = firestore.collection(Constant.users).document(userId)

        userRef.updateData([
            "createdCapsulesIds": FieldValue.arrayUnion([capsuleId])
        ]) { error in
            if let error = error {
                completion(.failure(error))
                return
            }

            // 如果收件者不是自己，更新或新增使用者的朋友欄位
            if recipientId != userId {
                self.updateFriendsList(userId: userId, recipientId: recipientId, updateInfo: updateInfo) { result in
                    switch result {
                    case .success():
                        self.updateRecipientCapsuleList(userId: userId, recipientId: recipientId, capsuleId: capsuleId, updateInfo: updateInfo, completion: completion)
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            } else {
                self.addCapsuleToReceivedList(userId: userId, capsuleId: capsuleId) { result in
                    switch result {
                    case .success():
                        completion(.success(()))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }

    func addCapsuleToReceivedList(userId: String, capsuleId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let userRef = firestore.collection("users").document(userId)

        userRef.updateData([
            "receivedCapsulesIds": FieldValue.arrayUnion([capsuleId])
        ]) { error in
            if let error = error {
                print("Failed to add capsule ID to receivedCapsulesIds: \(error)")
                completion(.failure(error))
            } else {
                print("Successfully added capsule ID to receivedCapsulesIds.")
                completion(.success(()))
            }
        }
    }

    func deleteCapsuleFromFirestore(capsuleId: String) {
        firestore.collection(Constant.capsules).document(capsuleId).delete { error in
            if let error = error {
                print("Error removing document: \(error.localizedDescription)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
}

// MARK: - Capsule media update operations
extension FirebaseManager {
    func uploadImage(_ image: UIImage, capsuleId: String, userId: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 1) else {
            completion(.failure(NSError(domain: "ImageError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])))
            return
        }

        let imageRef = storage.reference().child("images/\(capsuleId)/\(userId).jpg")

        imageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(.failure(error))
            } else {
                imageRef.downloadURL { url, error in
                    if let downloadURL = url {
                        completion(.success(downloadURL.absoluteString))
                    } else if let error = error {
                        completion(.failure(error))
                    }
                }
            }
        }
    }

    func uploadAudio(url: URL, capsuleId: String, userId: String ,completion: @escaping (Result<String, Error>) -> Void) {
        let audioRef = storage.reference().child("audio/\(capsuleId)/\(userId).m4a")

        let metadata = StorageMetadata()
        metadata.contentType = "audio/m4a"

        audioRef.putFile(from: url, metadata: metadata) { metadata, error in
            if let error = error {
                completion(.failure(error))
            } else {
                audioRef.downloadURL { url, error in
                    if let downloadURL = url {
                        completion(.success(downloadURL.absoluteString))
                    } else if let error = error {
                        completion(.failure(error))
                    }
                }
            }
        }
    }

    func uploadVideo(url: URL, capsuleId: String, userId: String, completion: @escaping (Result<String, Error>) -> Void) {
        let videoRef = storage.reference().child("videos/\(capsuleId)/\(userId).mp4")

        videoRef.putFile(from: url, metadata: nil) { metadata, error in
            if let error = error {
                completion(.failure(error))
            } else {
                videoRef.downloadURL { url, error in
                    if let downloadURL = url {
                        completion(.success(downloadURL.absoluteString))
                    } else if let error = error {
                        completion(.failure(error))
                    }
                }
            }
        }
    }
}

// MARK: - Users data operation
extension FirebaseManager {
    func saveUserToFirestore(user: User) {
        let userRef = firestore.collection(Constant.users).document(user.id)

        userRef.getDocument { document, error in
            if let error = error {
                print("Error fetching user data: \(error)")
                return
            }

            // 如果文檔存在，合併新數據
            if let document = document, document.exists {
                var existingData = document.data() ?? [:]

                // 更新現有資料的字段
                let newData = user.toDictionary()
                existingData["name"] = newData["name"]
                existingData["email"] = newData["email"]
                existingData["avatarUrl"] = newData["avatarUrl"]
                existingData["userIdentifier"] = newData["userIdentifier"]

                // 合併陣列字段
                if let createdCapsules = existingData["createdCapsulesIds"] as? [String] {
                    existingData["createdCapsulesIds"] = Array(Set(createdCapsules + (newData["createdCapsulesIds"] as? [String] ?? [])))
                }
                if let receivedCapsules = existingData["receivedCapsulesIds"] as? [String] {
                    existingData["receivedCapsulesIds"] = Array(Set(receivedCapsules + (newData["receivedCapsulesIds"] as? [String] ?? [])))
                }
                if let sharedCapsules = existingData["sharedCapsulesIds"] as? [String] {
                    existingData["sharedCapsulesIds"] = Array(Set(sharedCapsules + (newData["sharedCapsulesIds"] as? [String] ?? [])))
                }

                // 合併 friends
                if let existingFriends = existingData["friends"] as? [[String: Any]], let newFriends = newData["friends"] as? [[String: Any]] {
                    var mergedFriends = existingFriends
                    for friend in newFriends {
                        if !mergedFriends.contains(where: { ($0["id"] as? String) == friend["id"] as? String }) {
                            mergedFriends.append(friend)
                        }
                    }
                    existingData["friends"] = mergedFriends
                }

                userRef.setData(existingData) { error in
                    if let error = error {
                        print("Error updating user data: \(error)")
                    } else {
                        print("User data successfully updated in Firestore.")
                    }
                }

            } else {
                // 如果文檔不存在，創建新的用戶資料
                let userData = user.toDictionary()
                userRef.setData(userData) { error in
                    if let error = error {
                        print("Error saving new user data: \(error)")
                    } else {
                        print("New user data successfully saved to Firestore.")
                    }
                }
            }
        }
    }
}

// MARK: - Friend Data Operations
extension FirebaseManager {
    // 更新自己朋友列表
    private func updateFriendsList(userId: String, recipientId: String, updateInfo: CapsuleUpdateInfo, completion: @escaping (Result<Void, Error>) -> Void) {
        let userRef = firestore.collection(Constant.users).document(userId)

        userRef.getDocument { document, error in
            if let error = error {
                print("updateFriendsList Error fetching documents: \(error)")
                completion(.failure(error))
                return
            }

            guard let document = document, document.exists, var friends = document.data()?["friends"] as? [[String: Any]] else {
                completion(.failure(NSError(domain: "Document Error", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document does not exist"])))
                return
            }

            // 更新
            if let index = friends.firstIndex(where: { $0["id"] as? String == recipientId }) {
                friends[index]["latestInteractionDate"] = Date()
                friends[index]["fullName"] = updateInfo.content.toWhom == "You" ? "" : updateInfo.content.toWhom
            // 新增新朋友欄位
            } else {
                let friendData: [String: Any] = [
                    "id": recipientId,
                    "latestInteractionDate": Date(),
                    "fullName": updateInfo.content.toWhom == "You" ? "" : updateInfo.content.toWhom,
                    "avatar": "planet\(Int.random(in: 1...18))"
                ]
                friends.append(friendData)
            }

            userRef.updateData([
                "friends": friends
            ], completion: { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            })
        }
    }

    // 更新對方的膠囊列表
    private func updateRecipientCapsuleList(userId: String, recipientId: String, capsuleId: String, updateInfo: CapsuleUpdateInfo, completion: @escaping (Result<Void, Error>) -> Void) {
        let recipientRef = firestore.collection(Constant.users).document(recipientId)

        recipientRef.getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let document = document, document.exists, var recipientFriends = document.data()?["friends"] as? [[String: Any]] else {
                completion(.failure(NSError(domain: "Recipient Document Error", code: -1, userInfo: [NSLocalizedDescriptionKey: "Recipient document does not exist"])))
                return
            }

            // 更新或新增對方的朋友資訊
            if let index = recipientFriends.firstIndex(where: { $0["id"] as? String == userId }) {
                recipientFriends[index]["latestInteractionDate"] = Date()
                recipientFriends[index]["fullName"] = updateInfo.content.fromWhom == "Unknown" ? UserDefaults.standard.string(forKey: "userFullName") ?? "" : updateInfo.content.fromWhom
            } else {
                let recipientFriendData: [String: Any] = [
                    "id": userId,
                    "latestInteractionDate": Date(),
                    "fullName": updateInfo.content.fromWhom == "Unknown" ? UserDefaults.standard.string(forKey: "userFullName") ?? "" : updateInfo.content.fromWhom,
                    "avatar": "planet\(Int.random(in: 1...18))"
                ]
                recipientFriends.append(recipientFriendData)
            }

            // 更新收件者好友列表
            recipientRef.updateData([
                "receivedCapsulesIds": FieldValue.arrayUnion([capsuleId]),
                "friends": recipientFriends
            ], completion: { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            })
        }
    }

    func deleteFriendId(userId: String, friendId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let userRef = firestore.collection(Constant.users).document(userId)

        // 取得目前的好友列表
        userRef.getDocument { (document, error) in
            if let error = error {
                print("Error fetching document: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            guard let document = document, document.exists,
                  var friends = document.data()?["friends"] as? [[String: Any]] else {
                print("Document does not exist or friends data is not in correct format")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document does not exist or friends data is not in correct format"])))
                return
            }

            // 尋找並移除對應 friendId 的好友資料
            friends.removeAll { friend in
                return friend["id"] as? String == friendId
            }

            userRef.updateData(["friends": friends]) { error in
                if let error = error {
                    print("Error updating document: \(error.localizedDescription)")
                    completion(.failure(error))
                } else {
                    print("Friend successfully removed!")
                    completion(.success(()))
                }
            }
        }
    }

    func fetchFriendData(currentUserId: String, friendId: String, completion: @escaping (Result<User, Error>) -> Void) {

        let currentUserRef = firestore.collection(Constant.users).document(currentUserId)

        currentUserRef.getDocument { (document, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let document = document, document.exists,
                  let data = document.data(),
                  let friendsArray = data["friends"] as? [[String: Any]] else {
                print("Failed to fetch current user's friends list or list is empty.")
                completion(.failure(NSError(domain: "", code: -1,
                                            userInfo: [NSLocalizedDescriptionKey: "Failed to fetch current user's friends list"])))
                return
            }

            // 檢查朋友列表中是否包含該朋友
            let friendExists = friendsArray.contains { friendDict in
                return friendDict["id"] as? String == friendId
            }

            if friendExists {
                print("Friend \(friendId) already exists in the user's friends list.")
                if let friendDict = friendsArray.first(where: { $0["id"] as? String == friendId }),
                   let friend = Friend(dictionary: friendDict) {
                    FriendsCacheManager.shared.cacheFriend(friend)

                    // 回傳成功，並緩存朋友姓名＆ＩＤ至local
                    let user = User(id: friendId,
                                    email: nil,
                                    name: friend.fullName,
                                    avatarUrl: friend.avatar,
                                    createdCapsulesIds: nil,
                                    receivedCapsulesIds: nil,
                                    sharedCapsulesIds: nil,
                                    friends: nil,
                                    userIdentifier: nil)
                    completion(.success(user))

                } else {
                    completion(.failure(NSError(domain: "", code: -1,
                                                userInfo: [NSLocalizedDescriptionKey: "Failed to initialize friend from dictionary"])))
                }
                return
            }

            // 若朋友姓名尚未存在，則去 Constant.users 集合查找姓名
            let friendRef = self.firestore.collection(Constant.users).document(friendId)

            friendRef.getDocument { (document, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let document = document, document.exists else {
                    print("Document for friend \(friendId) does not exist.")
                    completion(.failure(NSError(domain: "", code: -1,
                                                userInfo: [NSLocalizedDescriptionKey: "Friend document not found"])))
                    return
                }

                let data = document.data()
                print("Fetched data for friend \(friendId): \(String(describing: data))")

                let name = data?["name"] as? String ?? "Unknown"
                let avatarUrl = data?["avatarUrl"] as? String ?? "planet2"

                let user = User(id: friendId,
                                email: nil,
                                name: name,
                                avatarUrl: avatarUrl,
                                createdCapsulesIds: nil,
                                receivedCapsulesIds: nil,
                                sharedCapsulesIds: nil,
                                friends: nil,
                                userIdentifier: nil)

                let friend = Friend(id: user.id,
                                    fullName: user.name ?? "Unknown",
                                    avatar: user.avatarUrl ?? "planet8",
                                    latestInteractionDate: Date())
                FriendsCacheManager.shared.cacheFriend(friend)

                completion(.success(user))
            }
        }
    }
}
