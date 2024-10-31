//
//  VideoPickerCardView.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/13.
//

import SwiftUI
import AVKit

struct VideoPickerCardView: View {
    @Binding var localVideoUrl: URL?
    @State private var showVideoPicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var player: AVPlayer?

    var body: some View {
        VStack {
            if let videoUrl = localVideoUrl {
                VideoPlayer(player: AVPlayer(url: videoUrl))
                    .frame(height: 200)
                    .padding()

                Button(action: {
                    clearVideoData()
                }, label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("刪除影片")
                    }
                    .padding()
                    .foregroundColor(.red)
                    .font(.headline)
                })
            } else {
                Image(systemName: "video.fill")
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
                    self.showVideoPicker = true
                }
                .padding()
                .font(.headline)
                .background(STColor.CC2.color.opacity(0.2))

                Spacer(minLength: 16)

                Button("錄製影片") {
                    self.sourceType = .camera
                    self.showVideoPicker = true
                }
                .padding()
                .background(STColor.CC2.color.opacity(0.4))
                .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))
                .font(.headline)

                Spacer()
            }
        }
        .sheet(isPresented: $showVideoPicker) {
            VideoPicker(videoUrl: $localVideoUrl, sourceType: sourceType)
        }
    }

    private func clearVideoData() {
        if let videoUrl = localVideoUrl {
            do {
                try FileManager.default.removeItem(at: videoUrl)
                print("成功删除影片: \(videoUrl)")
            } catch {
                print("删除影片失败: \(error.localizedDescription)")
            }
        }
        localVideoUrl = nil
        print("影片已刪除")
    }
}
