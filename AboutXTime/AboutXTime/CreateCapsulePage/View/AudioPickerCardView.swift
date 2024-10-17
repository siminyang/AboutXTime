//
//  AudioPickerCardView.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/13.
//

import SwiftUI
import AVFoundation

struct AudioPickerCardView: View {
    @StateObject private var audioRecorder = AudioRecorder()
    @Binding var localAudioUrl: URL?
    @State private var isRecordingAvailable: Bool = false

    var body: some View {
        VStack {
            if let audioURL = audioRecorder.audioURL ?? localAudioUrl {
                Button(action: {
                    audioRecorder.playAudio(url: audioURL)
                }) {
                    if audioRecorder.isAudioPlaying {
                        Image(systemName: "pause.circle")
                            .resizable()
                            .frame(width: 80, height: 80)
                    } else {
                        Image(systemName: "livephoto.play")
                            .resizable()
                            .frame(width: 80, height: 80)
                    }
                }
                .padding()

                Text("播放時間: \(formatTime(audioRecorder.playbackTime)) / \(formatTime(audioRecorder.audioDuration))")
                    .font(.subheadline)
                    .foregroundColor(.white)

                Slider(value: $audioRecorder.playbackTime,
                       in: 0...audioRecorder.audioDuration,
                       onEditingChanged: { isEditing in
                    if !isEditing {
                        audioRecorder.seek(to: audioRecorder.playbackTime)
                    }
                })
                .accentColor(.white)
                .padding(.horizontal)

                Button(action: {
                    deleteAudio()
                }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("刪除語音訊息")
                    }
                    .padding()
                    .foregroundColor(.red)
                    .font(.headline)
                }
            } else {
                // 顯示錄音進度
                ActivityIndicatorView(type: .lineScaleParty,
                                      color: .white, padding: nil,
                                      isAnimating: $audioRecorder.isRecording)
                    .frame(width: 35, height: 35)
                    .opacity(audioRecorder.isRecording ? 1 : 0)
                Image(systemName: "waveform")
                    .opacity(audioRecorder.isRecording ? 0 : 1)
                    .padding(.bottom)

                // 顯示錄製時間
                if audioRecorder.isRecording {
                    Text("錄製時間: \(formatTime(audioRecorder.recordingTime))")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.bottom)
                }

                // 錄音控制按鈕
                if audioRecorder.isRecording {
                    Button("停止錄音") {
                        audioRecorder.stopRecording()
                        print("audioRecorder.audioURL: \(String(describing: audioRecorder.audioURL))")
                    }
                    .padding()
                    .font(.headline)
                    .background(STColor.CC2.color.opacity(0.2))

                } else if !isRecordingAvailable {
                    Button("開始錄製") {
                        audioRecorder.startRecording()
                        audioRecorder.recordingFinished = { url in
                            DispatchQueue.main.async {
                                self.localAudioUrl = url
                                if url != nil {
                                    self.isRecordingAvailable = true // 隱藏「開始錄製」按鈕
                                }
                                print("錄音完成，localAudioUrl: \(String(describing: self.localAudioUrl))")
                            }
                        }
                    }
                    .padding()
                    .font(.headline)
                    .foregroundColor(.white)
                    .background(STColor.CC2.color.opacity(0.2))
                }
            }
        }
        .padding()
    }

    private func deleteAudio() {
        audioRecorder.reset()
        localAudioUrl = nil
        isRecordingAvailable = false // 顯示「開始錄製」按鈕
        print("音頻已刪除")
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
