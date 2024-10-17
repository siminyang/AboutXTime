//
//  ShowCapsuleReplyPopupView.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/30.
//

import Foundation
import SwiftUI

struct ShowCapsuleReplyPopupView: View {
    @ObservedObject var viewModel: CapsuleViewModel
    var dismissAction: () -> Void
    @State private var offset: CGFloat = 0  // 用来追踪手势的偏移量
    @State private var keyboardHeight: CGFloat = 0
    @AppStorage("userAvatar") private var avatarKey: String = "planet4"
    @State private var contentHeight: CGFloat = 0

    var body: some View {
        VStack {
            Spacer()

            ZStack(alignment: .topTrailing) {
                VStack {
                    VStack(alignment: .leading) {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 10) {
                                // 現有回覆
                                ForEach(viewModel.replyMessages, id: \.id) { reply in
                                    HStack(alignment: .top) {
                                        let cachedFriend =
                                        FriendsCacheManager.shared.getFriendFromCache(friendId: reply.userId)

                                        let friendAvatarImageName = cachedFriend?.avatar ?? "planet8"
                                        let friendName = cachedFriend?.fullName ?? "Unknown"

                                        Image(reply.userId ==
                                              UserDefaults.standard.string(forKey: "userUID") ?
                                              avatarKey : friendAvatarImageName)
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                            .clipShape(Circle())

                                        VStack(alignment: .leading) {

                                            Text((reply.userId ==
                                                  UserDefaults.standard.string(forKey: "userUID") ?
                                                  UserDefaults.standard.string(forKey: "userFullName") : friendName)
                                                 ?? "Unknown")
                                                .font(.caption)
                                                .foregroundColor(.white)

                                            Text(reply.text)
                                                .padding()
                                                .background(Color.gray.opacity(0.5))
                                                .cornerRadius(8)
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .padding(.vertical, 5)

                                    Text("回覆於 \(formatToMinute(date: reply.createdTime))")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .padding(.leading, 46)
                                }
                            }
                            .padding(.leading, 8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                GeometryReader { geo -> Color in
                                    DispatchQueue.main.async {
                                        self.contentHeight = geo.size.height
                                    }
                                    return Color.clear
                                }
                            )
                        }
                        .frame(height: min(contentHeight + 20, 300))
                        .frame(maxWidth: .infinity)

                        HStack(spacing: 8) {
                            Image(avatarKey)
                                .resizable()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())

                            CustomReplyTextEditor(text: $viewModel.replyText, placeholder: "新增留言")
                                .frame(height: 35)
                                .background(Color.gray.opacity(0.6))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                                .padding(.horizontal, 5)

                            Button(action: {
                                print("========================================按下送出")
                                viewModel.addReply()
                                hideKeyboard()
                            }) {
                                Image(systemName: "paperplane.fill")
                                    .padding()
                                    .foregroundColor(.gray)
                                    .frame(width: 40, height: 40)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 20)
                        .padding(.leading, 8)
                        .padding(.trailing, 8)
                    }
                    .padding()
                    .background(
                        VisualEffectBlur(blurStyle: .systemMaterial, colorTint: UIColor.black, colorTintAlpha: 0.8)
                    )
                    .cornerRadius(12)
                }
            }
            .offset(y: offset)
            .padding(.bottom, keyboardHeight)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        if gesture.translation.height > 0 { // 向下拖曳
                            offset = gesture.translation.height
                        }
                    }
                    .onEnded { _ in
                        if offset > 100 {
                            dismissAction()
                        }
                        offset = 0
                    }
            )
            .onAppear {
                setupKeyboardObservers()
            }
            .onDisappear {
                hideKeyboard()
                removeKeyboardObservers()
            }
            .frame(maxWidth: .infinity)
        }
        .background(
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    hideKeyboard()
                    dismissAction()
                }
        )
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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
