//
//  ShowCapsuleAudioView.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/17.
//

import Foundation
import SwiftUI

struct ShowCapsuleAudioView: View {
    let audioUrl: String
    @StateObject private var audioRecorder = AudioRecorder()

    var body: some View {
        VStack {
            if !audioUrl.isEmpty, let url = URL(string: audioUrl) {
                HStack {
                    // Play/Pause Button
                    Button(action: {
                        audioRecorder.playAudio(url: url)
                    }) {
                        ZStack {
                            ActivityIndicatorView(type: .lineScaleParty,
                                                  color: .white,
                                                  isAnimating: $audioRecorder.isAudioPlaying)
                                .frame(width: 35, height: 30)
                                .opacity(audioRecorder.isAudioPlaying ? 1 : 0)

                            Image(systemName: "waveform")
                                .resizable()
                                .imageScale(.medium)
                                .frame(width: 35, height: 30)
                                .opacity(audioRecorder.isAudioPlaying ? 0 : 1)
                        }
                        .padding()
                    }
                    .background(Color.white.opacity(0.1))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(STColor.CC2.color.opacity(0.5), lineWidth: 2)
                    )
                    .accessibilityLabel(audioRecorder.isAudioPlaying ? "Pause audio" : "Play audio")
                }

                    Text("\(formatTime(audioRecorder.playbackTime)) / \(formatTime(audioRecorder.audioDuration))")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.top, 8)

                    Slider(value: $audioRecorder.playbackTime,
                           in: 0...audioRecorder.audioDuration,
                           onEditingChanged: { isEditing in
                        if !isEditing {
                            audioRecorder.seek(to: audioRecorder.playbackTime)
                        }
                    })
                    .accentColor(.white)
                    .padding(.horizontal)
            }
        }
        .padding()
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
