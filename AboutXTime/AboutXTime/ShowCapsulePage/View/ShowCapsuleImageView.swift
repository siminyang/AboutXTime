//
//  ShowCapsuleImageView.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/17.
//

import SwiftUI
import PhotosUI

struct ShowCapsuleImageView: View {
    let imgUrl: String
    @State private var isAnimating: Bool = true
    @State private var showSaveAlert = false
    @State private var saveErrorMessage = ""
    @State private var downloadedImage: UIImage?

    var body: some View {
        if !imgUrl.isEmpty, let url = URL(string: imgUrl) {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .contextMenu {
                        Button(action: {
                            checkAndRequestPhotoLibraryAuthorization(url: url)
                        }, label: {
                            Text("儲存圖片")
                            Image(systemName: "square.and.arrow.down")
                        })
                    }
            } placeholder: {
                ProgressView()
            }
            .alert(isPresented: $showSaveAlert) {
                Alert(title: Text("儲存成功"), message: Text(saveErrorMessage), dismissButton: .default(Text("OK")))
            }
            .accessibilityLabel("Loaded image")
        }
    }

    private func checkAndRequestPhotoLibraryAuthorization(url: URL) {
        downloadImageInBackground(url: url)

        let currentStatus = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        if currentStatus == .authorized || currentStatus == .limited {
            saveImageToPhotos()
        } else if currentStatus == .notDetermined {
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { newStatus in
                if newStatus == .authorized || newStatus == .limited {
                    saveImageToPhotos()
                } else {
                    saveErrorMessage = "無法存取相簿，請在設定中啟用權限。"
                    showSaveAlert = true
                }
            }
        } else {
            saveErrorMessage = "無法存取相簿，請在設定中啟用權限。"
            showSaveAlert = true
        }
    }

    private func downloadImageInBackground(url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                saveErrorMessage = "下載圖片失敗: \(error.localizedDescription)"
                showSaveAlert = true
                return
            }
            if let data = data, let image = UIImage(data: data) {
                self.downloadedImage = image
            } else {
                saveErrorMessage = "載入圖片數據失敗。"
                showSaveAlert = true
            }
        }.resume()
    }

    // 保存圖片到相簿
    private func saveImageToPhotos() {
        guard let image = downloadedImage else {
            saveErrorMessage = "圖片下載未完成，請稍後再試。"
            showSaveAlert = true
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        saveErrorMessage = "圖片已儲存至相簿！"
        showSaveAlert = true
    }
}
