//
//  ShowCapsuleReplySectionView.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/17.
//

import Foundation
import SwiftUI

struct ShowCapsuleReplySectionView: View {
    @ObservedObject var viewModel: CapsuleViewModel
    let scrollViewProxy: ScrollViewProxy
    @AppStorage("userAvatar") private var avatarKey: String = "planet4"

    var body: some View {
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(viewModel.replyMessages, id: \.id) { reply in

                            HStack(alignment: .top) {
                                Image(avatarKey)
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .clipShape(Circle())

                                VStack(alignment: .leading) {
                                    Text(UserDefaults.standard.string(forKey: "userFullName") ?? "You")
                                        .font(.caption)
                                        .foregroundColor(.gray)

                                    Text(reply.text)
                                        .padding()
                                        .background(Color.gray.opacity(0.5))
                                        .cornerRadius(8)
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.vertical, 8)

                            Text("回覆於 \(formatToMinute(date: reply.createdTime))")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.leading, 40)
                        }

                        // 輸入回覆區域
                        HStack(spacing: 8) {
                            TextEditor(text: $viewModel.replyText)
                                .frame(height: 50)
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                )
                                .padding(.leading, 40)

                            Button(action: {
                                viewModel.addReply()
                                hideKeyboard()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation {
                                        scrollViewProxy.scrollTo("bottomAnchor", anchor: .bottom)
                                    }
                                }
                            }) {
                                Image(systemName: "paperplane.fill")
                                    .padding()
                                    .foregroundColor(.gray)
                                    .cornerRadius(8)
                            }
                        }

                        .padding(.top, 20)
                    }
                    .padding(.horizontal)
                    .id("bottomAnchor")
                }
                .onChange(of: viewModel.replyMessages) { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            scrollViewProxy.scrollTo("bottomAnchor", anchor: .bottom)
                        }
                    }
                }
            }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
