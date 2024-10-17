//
//  CardViewModel.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/13.
//

import Foundation
import SwiftUI
import Combine
import Firebase
import GoogleGenerativeAI

class CardViewModel: ObservableObject {
    @Published var capsuleId: String?
    @Published var currentIndex = 0

    @Published var text = ""
    @Published var fromWhom: String = ""
    @Published var toWhom: String = ""
    @Published var image: UIImage?
    @Published var localImageUrl: URL?
    @Published var imageUrl: String?
    @Published var localAudioUrl: URL?
    @Published var audioUrl: String?
    @Published var localVideoUrl: URL?
    @Published var videoUrl: String?

//    @Published var settings = CardModel()
    @Published var userId: String
    @Published var isAnonymous = false
    @Published var isLocationLocked = false
    @Published var openDate = Date()
    @Published var recipient = ""
    @Published var currentLatitude: Double?
    @Published var currentLongitude: Double?
    @Published var currentRadius: Int?
    @Published var isShared = false

    @Published var imageTagLabels: [Int] = []
    @Published var emotionTagLabels: [String] = []
    @Published var errorMessage: String?
    @Published var response: String = "Loading..."
    @Published var recommendedLabels: [String] = []

    private var cancellables = Set<AnyCancellable>()
    private var classifier: ClassificationInference?
    private var model = GenerativeModel(name: "gemini-1.5-flash-latest", apiKey: "")

    static let shared = CardViewModel()

    init(capsuleId: String? = nil, recipient: String = "") {

        guard let savedUserId = UserDefaults.standard.string(forKey: "userUID") else {
            print("User UID not found in UserDefaults, using default value.")
            self.userId = "defaultUserId"
            self.capsuleId = capsuleId
            self.recipient = recipient
            return
        }

        self.capsuleId = capsuleId
        self.userId = savedUserId
        self.recipient = recipient

        if let apiKey = getAPIKey() {
            self.model = GenerativeModel(name: "gemini-1.5-flash-latest", apiKey: apiKey)
        } else {
            fatalError("API Key not found")
        }

        print(">>>> CardViewModel initialized with capsuleId: \(capsuleId ?? "nil")")
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.initializeClassifier()
        }
    }

    private func initializeClassifier() {
        self.classifier = ClassificationInference()
        print(">>>> Classifier initialized in background thread.")
    }

    func nextCard() {
        if currentIndex < 4 { currentIndex += 1 }
    }

    func previousCard() {
        if currentIndex > 0 { currentIndex -= 1 }
    }

    func handleSelectedImage(_ image: UIImage) {
        self.image = image
        print("開始執行圖像分類")
        classifier?.performInference(on: image) { [weak self] labelIndices in
            DispatchQueue.main.async {
                self?.imageTagLabels = labelIndices
                print("圖像分類完成，標籤索引：\(labelIndices)")
            }
        }
    }

    func fetchContent() async {
        let prompt = """
        以下會給你一段文字，和一段情緒感受的分類標籤，閱讀後請挑選出「三個」最適合的心情類別標籤，直接給我三個標籤文字就好，回傳的標籤格式前面要分別加上hashtag"#"，並且三個標籤用頓號分隔，例如：#開心、#有自信、#興奮。如果無法從這段文字中辨別出任何情緒感受，或是這段文字為空值，請回傳：#平靜。
                        let emotions = [
                        "快樂": ["開心", "有自信", "興奮", "痛快", "舒適"],
                        "得意": ["高興", "歡喜", "狂喜", "寧靜"],
                        "幸福": ["愉快", "滿足", "沾沾自喜"],
                        "雀躍": ["喜樂", "有希望", "有信心"],
                        "輕鬆": ["平靜", "安心", "釋懷", "寬恕"],
                        "憤怒": ["憤怒", "煩躁", "妒忌", "生氣", "不平", "憤恨", "不滿"],
                        "暴躁": ["不耐煩", "焦躁"],
                        "悲傷": ["孤單", "憂傷", "無助", "失望", "哀傷", "抑鬱", "悶悶不樂", "哀慟", "憂鬱", "空虛"],
                        "委屈": ["沮喪", "絕望", "無奈", "難過"],
                        "失落": ["氣餒", "心痛", "挫敗", "委屈"],
                        "哀痛": ["傷心", "不開心", "遺憾", "無望"],
                        "無力": ["徬徨", "孤立無援", "麻木", "苦惱"],
                        "煩惱": ["心淡", "心力交瘁", "心煩意亂"],
                        "恐懼": ["害怕", "緊張", "擔心", "不安", "焦急", "慌張", "恐懼", "憂心", "疑慮", "憂慮"],
                        "迷惘": ["迷失", "戰戰兢兢", "畏懼", "焦慮"],
                        "惶恐": ["擔憂", "忐忑", "心慌意亂"],
                        "驚訝": ["震驚", "訝異", "驚喜", "嘆為觀止"],
                        "厭惡": ["輕視", "輕蔑", "譏諷", "討厭", "憎惡", "厭倦"],
                        "羞恥": ["內疚", "愧疚", "尷尬", "懊悔", "恥辱"],
                        "自責": ["慚愧", "悔恨", "遺憾", "自卑", "難堪"],
                        "愛": ["友善", "和善", "親密", "信賴", "寵愛", "被接納", "被信任", "感動", "被愛"]
                        ]
        待辨識的文字內容：
        \(text)
        """

        do {
            let response = try await model.generateContent(prompt)
            DispatchQueue.main.async {
                self.response = response.text ?? "No response"
                print(">>>> Response: \(self.response)")
            }
        } catch {
            DispatchQueue.main.async {
                self.response = "Error: \(error.localizedDescription)"
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    func getAPIKey() -> String? {
        if let path = Bundle.main.path(forResource: "APIKey", ofType: "plist"),
           let xml = FileManager.default.contents(atPath: path),
           let keyDict = try? PropertyListSerialization.propertyList(from: xml,
                                                                     options: .mutableContainersAndLeaves,
                                                                     format: nil) as? [String: String] {
            return keyDict["apiKey"]
        }
        return nil
    }

    private func resetToInitialCreationPageAndNavigateToPending() {
        NotificationCenter.default.post(name: .resetCreationPageAndNavigateToPending, object: nil)
    }

    func submitCapsule(completion: @escaping (Bool) -> Void) {
        print(">>>> 上傳確認 capsuleId: \(capsuleId ?? "nil")")

        var errorMessages: [String] = []

        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || text == "今天天氣很好，覺得充滿動力！ (必填)" {
            errorMessages.append("膠囊文字訊息不能為空👀")
        }

        if isAnonymous == false && fromWhom.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessages.append("請填寫 Card 2 寄件人欄位名稱")
        }

        if toWhom.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessages.append("請填寫 Card 2 收件人欄位名稱🙂‍↕️")
        }

        if recipient.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessages.append("請輸入收件者ID")
        }

        let now = Date().addingTimeInterval(60 * 10)
        if openDate <= now {
            errorMessages.append("開啟時間必須至少為十分鐘後🧐")
        }

        if !errorMessages.isEmpty {
            errorMessage = errorMessages.joined(separator: "\n")
            showAlert()
            completion(false)
            return
        }

        // 驗證收件者 ID 是否存在於 Firestore 中
        validateRecipientId { [weak self] isValid in
            guard let self = self else { return }

            if !isValid {
                self.errorMessage = "收件者 ID 不存在。請確認後再試一次。"
                self.showAlert()
                completion(false)
                return
            }

            if self.capsuleId == nil {
                FirebaseManager.shared.createCapsule { [weak self] result in
                    switch result {
                    case .success(let newCapsuleId):
                        self?.capsuleId = newCapsuleId
                        self?.performCapsuleUpdate(completion: completion)
                        print(">>>> 新創建的 capsuleId: \(newCapsuleId)")
                    case .failure(let error):
                        self?.errorMessage = "創建膠囊失敗: \(error.localizedDescription)"
                        self?.showAlert()
                        completion(false)
                    }
                }
            } else {
                self.performCapsuleUpdate(completion: completion)
            }
        }
    }

    private func showAlert() {
        NotificationCenter.default.post(name: .showAlert, object: nil)
    }

    private func validateRecipientId(completion: @escaping (Bool) -> Void) {
        if recipient.contains("/") {
            print("Invalid recipient ID format: cannot contain '/' character")
            completion(false)
            return
        }

        let recipientRef = Firestore.firestore().collection("users").document(recipient)

        recipientRef.getDocument { document, error in
            if let error = error {
                print("Error checking recipient ID: \(error.localizedDescription)")
                completion(false)
                return
            }

            if let document = document, document.exists {
                completion(true)

            } else {
                completion(false)
            }
        }
    }

    private func performCapsuleUpdate(completion: @escaping (Bool) -> Void) {
        guard let capsuleId = capsuleId else {
            print(">>>> 錯誤：capsuleId 為 nil，無法更新")
            completion(false)
            return
        }

        print(">>>> 開始更新 capsuleId: \(capsuleId)")

        let group = DispatchGroup()
        var imageUrl: String?
        var audioUrl: String?
        var videoUrl: String?
        var uploadErrors: [String] = []

        group.enter()
        uploadImageIfNeeded(capsuleId: capsuleId) { url, error in
            if let url = url {
                imageUrl = url
            }
            if let error = error {
                uploadErrors.append(error)
            }
            group.leave()
        }

        group.enter()
        uploadAudioIfNeeded(capsuleId: capsuleId) { url, error in
            if let url = url {
                audioUrl = url
            }
            if let error = error {
                uploadErrors.append(error)
            }
            group.leave()
        }

        group.enter()
        uploadVideoIfNeeded(capsuleId: capsuleId) { url, error in
            if let url = url {
                videoUrl = url
            }
            if let error = error {
                uploadErrors.append(error)
            }
            group.leave()
        }

        group.notify(queue: .main) { [weak self] in
            guard let self = self else {
                completion(false)
                return
            }

            if !uploadErrors.isEmpty {
                self.errorMessage = uploadErrors.joined(separator: "\n")
                print("上傳錯誤: \(self.errorMessage ?? "")")
                completion(false)
                return
            }

            self.executeCapsuleUpdate(capsuleId: capsuleId,
                                      imageUrl: imageUrl,
                                      audioUrl: audioUrl,
                                      videoUrl: videoUrl,
                                      completion: completion)
        }
    }
}

extension CardViewModel {
    private func uploadImageIfNeeded(capsuleId: String, completion: @escaping (String?, String?) -> Void) {
        guard let image = image else {
            completion(nil, nil)
            return
        }

        FirebaseManager.shared.uploadImage(image, capsuleId: capsuleId, userId: userId) { result in
            switch result {
            case .success(let url):
                print("圖片上傳成功: \(url)")
                completion(url, nil)
            case .failure(let error):
                completion(nil, "圖片上傳失敗: \(error.localizedDescription)")
            }
        }
    }

    private func uploadAudioIfNeeded(capsuleId: String, completion: @escaping (String?, String?) -> Void) {
        guard let audioFileUrl = localAudioUrl else {
            completion(nil, nil)
            return
        }

        FirebaseManager.shared.uploadAudio(url: audioFileUrl, capsuleId: capsuleId, userId: userId) { result in
            switch result {
            case .success(let url):
                print("音訊上傳成功: \(url)")
                completion(url, nil)
            case .failure(let error):
                completion(nil, "音訊上傳失敗: \(error.localizedDescription)")
            }
        }
    }

    private func uploadVideoIfNeeded(capsuleId: String, completion: @escaping (String?, String?) -> Void) {
        guard let videoFileUrl = localVideoUrl else {
            completion(nil, nil)
            return
        }

        FirebaseManager.shared.uploadVideo(url: videoFileUrl, capsuleId: capsuleId, userId: userId) { result in
            switch result {
            case .success(let url):
                print("影片上傳成功: \(url)")
                completion(url, nil)
            case .failure(let error):
                completion(nil, "影片上傳失敗: \(error.localizedDescription)")
            }
        }
    }

    private func executeCapsuleUpdate(capsuleId: String,
                                      imageUrl: String?,
                                      audioUrl: String?,
                                      videoUrl: String?,
                                      completion: @escaping (Bool) -> Void) {
        guard let userId = UserDefaults.standard.string(forKey: "userUID") else {
            print("Failed to get UID from UserDefaults.")
            completion(false)
            return
        }

        let from = fromWhom.isEmpty ? "Unknown" : fromWhom
        let to = toWhom.isEmpty ? "You" : toWhom

        let content = Content(
            imgUrl: imageUrl, text: text,
            audioUrl: audioUrl, videoUrl: videoUrl,
            userId: userId,
            fromWhom: from, toWhom: to
        )

        let location = Location(
            latitude: currentLatitude,
            longitude: currentLongitude,
            radius: currentRadius
        )

        let updateInfo = CapsuleUpdateInfo(
            content: content,
            openDate: openDate,
            location: location,
            isAnonymous: isAnonymous,
            isLocationLocked: isLocationLocked,
            isShared: isShared,
            recipient: recipient,
            emotionTagLabels: emotionTagLabels
        )

        FirebaseManager.shared.updateCapsuleContent(capsuleId: capsuleId,
                                                    updateInfo: updateInfo,
                                                    imageTagLabels: imageTagLabels) { [weak self] result in
            switch result {
            case .success:
                print("膠囊內容更新成功！")
                self?.deleteLocalFiles()
                self?.resetToInitialCreationPageAndNavigateToPending()
                completion(true)
            case .failure(let error):
                self?.errorMessage = "儲存膠囊失敗: \(error.localizedDescription)"
                print(self?.errorMessage ?? "")
                self?.showAlert()
                completion(false)
            }
        }
    }

    private func deleteLocalFiles() {
        if let localImageUrl = localImageUrl, localImageUrl.isFileURL {
            deleteLocalFile(at: localImageUrl)
        }

        if let localAudioUrl = localAudioUrl, localAudioUrl.isFileURL {
            deleteLocalFile(at: localAudioUrl)
        }

        if let localVideoUrl = localVideoUrl, localVideoUrl.isFileURL {
            deleteLocalFile(at: localVideoUrl)
        }
    }

    private func deleteLocalFile(at url: URL) {
        guard FileManager.default.fileExists(atPath: url.path) else {
            print("文件不存在，無法刪除: \(url)")
            return
        }

        do {
            try FileManager.default.removeItem(at: url)
            print("成功删除本地文件: \(url)")
        } catch {
            print("删除本地文件失败: \(error.localizedDescription)")
        }
    }
}
