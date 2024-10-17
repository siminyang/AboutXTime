//
//  ImagePickerCardView.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/13.
//

import SwiftUI

struct ImagePickerCardView: View {
    @ObservedObject var viewModel: CardViewModel
    @State private var showImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary

    var body: some View {
        VStack {
            if let image = viewModel.image {

                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .padding()

                Button(action: {
                    clearImageData()
                }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("刪除圖片")
                    }
                    .padding()
                    .foregroundColor(.red)
                    .font(.headline)
                }
                .padding(.bottom)

            } else {
                Image(systemName: "photo")
                    .padding()
                    .frame(width: 300, height: 300)
                    .background(Color.white.opacity(0.3))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(STColor.CC2.color, lineWidth: 1)
                    )
                    .foregroundColor(.white)
                    .padding(.bottom)
            }

            HStack {
                Spacer()

                Button("從相簿選擇") {
                    self.sourceType = .photoLibrary
                    self.showImagePicker = true
                }
                .padding(10)
                .font(.headline)
                .foregroundColor(.white)
                .background(STColor.CC2.color.opacity(0.2))

                Spacer(minLength: 16)

                Button("拍攝照片") {
                    self.sourceType = .camera
                    self.showImagePicker = true
                }
                .padding(10)
                .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))
                .font(.headline)
                .foregroundColor(.white)
                .background(STColor.CC2.color.opacity(0.4))

                Spacer()
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: Binding(
                get: { self.viewModel.image },
                set: { newImage in
                    if let newImage = newImage {
                        self.viewModel.handleSelectedImage(newImage)
                    }
                }
            ), imageUrl: $viewModel.localImageUrl, sourceType: sourceType)
        }
        .onChange(of: showImagePicker) { _ in
        }
    }

    private func clearImageData() {
        viewModel.image = nil
        viewModel.localImageUrl = nil
    }
}
