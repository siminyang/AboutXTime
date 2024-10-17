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

    var body: some View {
        if !imgUrl.isEmpty, let url = URL(string: imgUrl) {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .contextMenu {
                        Button(action: {
                            saveImageToPhotos(url: url)
                        }) {
                            Text("儲存圖片")
                            Image(systemName: "square.and.arrow.down")
                        }
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

    // 保存圖片到相簿
    private func saveImageToPhotos(url: URL) {

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                saveErrorMessage = "Failed to download image: \(error.localizedDescription)"
                showSaveAlert = true
                return
            }
            guard let data = data, let image = UIImage(data: data) else {
                saveErrorMessage = "Failed to load image data."
                showSaveAlert = true
                return
            }

            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            saveErrorMessage = "圖片已儲存至相簿！"
            showSaveAlert = true
        }.resume()
    }
}
