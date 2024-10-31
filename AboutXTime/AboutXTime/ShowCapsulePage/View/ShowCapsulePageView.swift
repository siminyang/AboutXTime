//
//  ShowCapsulePageView.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/16.
//

import SwiftUI
import AVKit

struct ShowCapsulePageView: View {
    @StateObject private var viewModel: CapsuleViewModel
    @State private var keyboardHeight: CGFloat = 0
    @State private var showReplyPopup: Bool = false
    var capsule: Capsule
    var content: Content

    init(capsule: Capsule, content: Content) {
        _viewModel = StateObject(wrappedValue: CapsuleViewModel(capsule: capsule))
        self.capsule = capsule
        self.content = content
    }

    var body: some View {
        ZStack {
                ScrollView {
                    Spacer().frame(height: 80)

                    VStack(alignment: .leading, spacing: 20) {

                        if let imgUrl = content.imgUrl, !imgUrl.isEmpty {
                            ShowCapsuleImageView(imgUrl: imgUrl)
                        }

                        Spacer()

                        ShowCapsuleTextView(text: content.text)

                        if let emotionTagLabels = capsule.emotionTagLabels, !emotionTagLabels.isEmpty {
                            Spacer()
                            ShowCapsuleEmotionTagView(emotionTagLabels: emotionTagLabels)
                        }

                        if let audioUrl = content.audioUrl, !audioUrl.isEmpty {
                            Spacer(minLength: 30)
                            ShowCapsuleAudioView(audioUrl: audioUrl)
                                .alignmentGuide(.top) { $0[.top] }
                        }

                        if let videoUrl = content.videoUrl, !videoUrl.isEmpty {
                            Spacer(minLength: 30)
                            HStack {
                                Spacer()
                                ShowCapsuleVideoView(videoUrl: videoUrl)
                                Spacer()
                            }
                        }

                        Spacer(minLength: 50)

                        ShowCapsuleInfoView(capsule: viewModel.capsuleInfo,
                                            userId: content.userId,
                                            fromWhom: content.fromWhom,
                                            toWhom: content.toWhom)
                            .padding()

                        Spacer()

                        Button(action: {
                            withAnimation {
                                showReplyPopup.toggle()
                            }
                        }, label: {
                            HStack {
                                Spacer()
                                Image(systemName: "message.fill")
                                Spacer().frame(width: 8)
                                Text("\(viewModel.replyMessages.count)")
                                    .font(.subheadline)
                                    .padding(6)
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(STColor.CC1.color.opacity(0.5), lineWidth: 2)
                            )
                        })
                        .padding(.horizontal)

                        Spacer()
                    }
                    .padding()
                    .scrollContentBackground(.hidden)
                    .background(Color.black)
                    .edgesIgnoringSafeArea(.all)
                }
                .padding(.bottom, keyboardHeight + 50)
                .onAppear {
                    viewModel.startListening()
                    setupKeyboardObservers()
                    viewModel.updateCapsuleStatus()
                }
                .onDisappear {
                    viewModel.stopListening()
                    removeKeyboardObservers()
                }
                .onTapGesture {
                    hideKeyboard()
                }
                .background(Color.black)
                .edgesIgnoringSafeArea(.all)

            if showReplyPopup {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            showReplyPopup = false
                        }
                    }
                ShowCapsuleReplyPopupView(viewModel: viewModel) {
                    withAnimation {
                        showReplyPopup = false
                    }
                }
            }
        }
    }

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil, queue: .main) { notification in

                if let keyboardFrame: NSValue =
                    notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                    let keyboardRectangle = keyboardFrame.cgRectValue
                    keyboardHeight = keyboardRectangle.height
                }
            }

        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil, queue: .main) { _ in
                keyboardHeight = 0
            }
    }

    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}
