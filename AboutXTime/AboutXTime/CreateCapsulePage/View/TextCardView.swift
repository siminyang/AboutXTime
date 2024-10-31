//
//  TextCardView.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/13.
//

import SwiftUI

struct TextCardView: View {
    @Binding var text: String
    @Binding var fromWhom: String
    @Binding var toWhom: String
    @State private var recommendedLabels: [String] = []
    @State private var selectedLabels: Set<String> = []
    @State private var typingTimer: Timer?
    @State private var isNotFocused: Bool = true
    @State private var keyboardHeight: CGFloat = 0
    @ObservedObject var viewModel: CardViewModel
    @State private var isCustomSentTextFieldFocused: Bool = false
    @State private var isAnimating = false

    var body: some View {
        VStack {
            CustomTextField(text: $toWhom, placeholder: "To: 三年後的自己 (必填)")
                .frame(height: 30)
                .cornerRadius(10)
                .onTapGesture {
                    removeKeyboardObservers()
                    isCustomSentTextFieldFocused = false
                }
                .padding(.bottom, 10)

            CustomTextEditor(placeholder: "今天天氣很好，覺得充滿動力！ (必填)", text: $text, isNotFocused: $isNotFocused, fontSize: 14)
                .cornerRadius(10)
                .frame(height: 150)
                .padding(.bottom, 20)
                .onTapGesture {
                    removeKeyboardObservers()
                    isCustomSentTextFieldFocused = false
                }
                .onChange(of: isNotFocused) {
                    if isNotFocused {
                        triggerFetchContent()
                    }
                }

            Text("等待五秒鐘，會依照文字內容產生心情標籤～")
                .foregroundColor(.white)
                .font(.caption)
                .padding(.bottom, 10)

            if !viewModel.response.isEmpty {
                Text("選擇符合當下心情的標籤：")
                    .foregroundColor(.white)
                    .font(.caption)
                    .padding(.bottom, 10)

                HStack(spacing: 10) {
                    if recommendedLabels.isEmpty {
                        Text("Loading...")
                            .padding(10)
                            .font(.body)
                            .foregroundColor(STColor.CC2.color)
                            .offset(x: isAnimating ? -20 : 20)
                            .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true),
                                       value: isAnimating)
                            .onAppear {
                                isAnimating = true
                            }

                    } else {
                        ForEach(recommendedLabels, id: \.self) { label in
                            Text(label)
                                .padding(10)
                                .font(.subheadline)
                                .background(
                                    selectedLabels.contains(label) ? Color.black.opacity(0.5) : Color.gray.opacity(0.5))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .onTapGesture {
                                    toggleLabelSelection(label)
                                }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom, 20)
            }

            CustomTextField(text: $fromWhom, placeholder: "From: 三年前的自己")
                .frame(height: 30)
                .cornerRadius(10)
                .onTapGesture {
                    setupKeyboardObservers()
                    isCustomSentTextFieldFocused = true
                }
        }
        .padding()
        .cornerRadius(20)
        .offset(y: isCustomSentTextFieldFocused ? -keyboardHeight / 3 : 0)
        .onAppear {
            if isCustomSentTextFieldFocused {
                setupKeyboardObservers()
            }
        }
        .onDisappear {
            removeKeyboardObservers()
        }
        .onChange(of: isCustomSentTextFieldFocused) {
            if !isCustomSentTextFieldFocused {
                removeKeyboardObservers()
            }
        }
    }

    private func debounceTextInput(_ newText: String) {
        typingTimer?.invalidate()
        typingTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { _ in
            if !newText.isEmpty {
                triggerFetchContent()
            }
        }
    }

    @MainActor
    private func triggerFetchContent() {
        Task {
            await viewModel.fetchContent()
            self.recommendedLabels = viewModel.response
                .components(separatedBy: "、")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        }
    }

    private func toggleLabelSelection(_ label: String) {
        if selectedLabels.contains(label) {
            selectedLabels.remove(label)
        } else {
            selectedLabels.insert(label)
        }
        viewModel.emotionTagLabels = Array(selectedLabels)
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
