//
//  ShowCapsuleVideoView.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/17.
//

import Foundation
import SwiftUI
import _AVKit_SwiftUI
import AVKit

struct ShowCapsuleVideoView: View {
    let videoUrl: String
    @State private var player: AVPlayer?
    @State private var isVideoEnded = false
    @State private var showFullScreenPlayer = false

    var body: some View {
        VStack {
            if !videoUrl.isEmpty, let url = URL(string: videoUrl) {
                Button(action: {
                    setupPlayer(url: url)
                    showFullScreenPlayer = true
                }) {
                    Image(systemName: "video.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 35, height: 30)
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .foregroundColor(.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(STColor.CC2.color.opacity(0.5), lineWidth: 2)
                )
                .fullScreenCover(isPresented: $showFullScreenPlayer) {
                    ZStack {
                        Color.black
                            .edgesIgnoringSafeArea(.all)
                        VideoPlayer(player: player)
                            .onAppear {
                                player?.play()
                                addVideoEndObserver()
                            }
                            .onDisappear {
                                player?.pause()
                            }

                        // 關閉按鈕
                        VStack {
                            HStack {
                                Spacer()
                                Button(action: {
                                    showFullScreenPlayer = false
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.largeTitle)
                                        .foregroundColor(.white)
                                        .padding()
                                }
                            }
                            Spacer()
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    // 初始化播放器
    private func setupPlayer(url: URL) {
        let playerItem = AVPlayerItem(url: url)
        DispatchQueue.main.async {
            player = AVPlayer(playerItem: playerItem)
        }
    }

    // 添加影片結束的監聽器
    private func addVideoEndObserver() {
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { _ in
            isVideoEnded = true
            showFullScreenPlayer = false
        }
    }
}
