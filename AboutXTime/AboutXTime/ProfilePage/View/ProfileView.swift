//
//  ProfileView.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/24.
//

import Foundation
import SwiftUI

// MARK: - ProfileView
struct ProfileView: View {
    @StateObject private var viewModel: ProfileViewModel
    @AppStorage("userAvatar") private var userAvatar: String = "planet4"

    @State private var newFriendName: String = ""
    @State private var selectedFriendId: String?

    init(userID: String) {
        _viewModel = StateObject(wrappedValue: ProfileViewModel(userID: userID))
    }

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Image(userAvatar)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .shadow(radius: 5)
                    .onTapGesture {
                        viewModel.changeUserAvatar()
                    }

                Text(viewModel.userFullName)
                    .font(.title)
                    .foregroundColor(.white)
                    .bold()

                HStack {
                    Button(action: {
                        UIPasteboard.general.string = viewModel.userID
                        viewModel.showCopyNotification()
                    }, label: {
                        HStack {
                            Text("ID: \(viewModel.userID)")
                                .font(.caption)
                                .foregroundColor(.gray)

                            Image(systemName: "doc.on.doc")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                        }
                    })
                    .buttonStyle(PlainButtonStyle())

                    ShareLink(item: viewModel.userID) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.gray)
                            .font(.headline)
                    }
                }
                .padding(.bottom, 45)

                // MARK: 好友列表
                Text("最近互動")
                    .font(.caption)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 16)

                if viewModel.friends.isEmpty {
                    Text("還沒有寄送膠囊給好友嗎？🤔\n試著分享你的第一個膠囊吧，讓驚喜傳遞出去！✨")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 50)
                } else {
                    ScrollView(.horizontal) {
                        LazyHStack(spacing: 20) {
                            ForEach(viewModel.friends) { friend in
                                ZStack(alignment: .topTrailing) {
                                    FriendRowList(
                                        viewModel: viewModel,
                                        friend: friend,
                                        onEditName: { newFriendName in
                                            viewModel.updateFriendName(friendID: friend.id, newName: newFriendName)},
                                        onCopyID: {
                                            UIPasteboard.general.string = friend.id
                                            viewModel.showCopyNotification()
                                        }, 
                                        onChangeAvater: {
                                            viewModel.changeFriendAvatar(friendID: friend.id)
                                        },
                                        onReport: {
                                            selectedFriendId = friend.id
                                            viewModel.alertType = .report
                                        },
                                        onBlock: {
                                            selectedFriendId = friend.id
                                            viewModel.alertType = .block
                                        },
                                        onDelete: {
                                            selectedFriendId = friend.id
                                            viewModel.alertType = .delete
                                        }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .frame(height: 250)
                }
                Spacer()
            }
            .padding()
            .alert(item: $viewModel.alertType) { alertType in
                switch alertType {
                case .report:
                    return Alert(
                        title: Text("確定要檢舉嗎？"),
                        message: Text("這將向系統報告該用戶。"),
                        primaryButton: .destructive(Text("確定")) {
                            print("按下確定")
                            if let friendId = selectedFriendId {
                                print("id ======= \(friendId)")
                                viewModel.reportFriend(friendId: friendId)
                            }
                            viewModel.alertType = .reportConfirmation
                        },
                        secondaryButton: .cancel()
                    )
                case .block:
                    return Alert(
                        title: Text("確定要封鎖嗎？"),
                        message: Text("該用戶將無法與您互動。"),
                        primaryButton: .destructive(Text("確定")) {
                            if let friendId = selectedFriendId {
                                viewModel.blockFriend(friendId: friendId)
                            }
                            viewModel.alertType = .blockConfirmation
                        },
                        secondaryButton: .cancel()
                    )
                case .delete:
                    return Alert(
                        title: Text("確定要刪除好友嗎？"),
                        message: Text("刪除後將無法恢復。"),
                        primaryButton: .destructive(Text("確定")) {
                            if let friendId = selectedFriendId {
                                viewModel.deleteFriend(friendId: friendId)
                            }
                            viewModel.alertType = .deleteConfirmation
                        },
                        secondaryButton: .cancel()
                    )
                case .reportConfirmation:
                    return Alert(
                        title: Text("已向系統回報"),
                        message: Text("您的檢舉已經提交。"),
                        dismissButton: .default(Text("確定")) {
                            viewModel.alertType = nil
                        }
                    )
                case .blockConfirmation:
                    return Alert(
                        title: Text("封鎖成功"),
                        message: Text("該用戶已被封鎖。"),
                        dismissButton: .default(Text("確定")) {
                            viewModel.alertType = nil
                        }
                    )
                case .deleteConfirmation:
                    return Alert(
                        title: Text("好友已刪除"),
                        message: Text("該用戶已從您的好友列表中刪除。"),
                        dismissButton: .default(Text("確定")) {
                            viewModel.alertType = nil
                        }
                    )
                case .error:
                    return Alert(
                        title: Text("操作失敗"),
                        message: Text("網路連線異常，請稍後再試。"),
                        dismissButton: .default(Text("確定")) {
                            viewModel.alertType = nil
                        }
                    )
                }
            }

            if viewModel.isShowingCopyAlert {
                VStack {
                    Spacer()
                    Text("已複製到剪貼板!")
                        .font(.caption)
                        .padding(8)
                        .frame(height: 50)
                        .background(Color.white.opacity(0.1))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .transition(.opacity)
                .zIndex(1)
            }
        }
    }
}

// MARK: - FriendRowList
struct FriendRowList: View {

    @ObservedObject var viewModel: ProfileViewModel
    let friend: Friend
    let onEditName: (String) -> Void
    let onCopyID: () -> Void
    let onChangeAvater: () -> Void
    let onReport: () -> Void
    let onBlock: () -> Void
    let onDelete: () -> Void

    @State private var isEditingName = false
    @State private var newFriendName = ""

    var body: some View {
        VStack {
            Image(friend.avatar)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                .shadow(radius: 5)
                .onTapGesture {
                    onChangeAvater()
                }
                .padding()

            HStack {
                if isEditingName {
                    TextField("Name", text: $newFriendName)
                        .font(.body)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 100)
                        .background(Color.white.opacity(0.2))
                        .onSubmit {
                            onEditName(newFriendName)
                            isEditingName = false
                        }
                } else {
                    Text(friend.fullName)
                        .font(.caption)
                        .foregroundColor(.white)
                }

                Button(action: {
                    isEditingName = true
                    newFriendName = friend.fullName
                }, label: {
                    Image(systemName: "pencil")
                        .foregroundColor(.gray)
                })
            }
            .padding(.bottom, 30)

            Button(action: onCopyID) {
                HStack {
                    Text("ID: \(friend.id)")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)

                    Image(systemName: "doc.on.doc")
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
            }
        }
        .frame(width: 150, height: 250)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)

        Menu {
            Button(action: {
                onReport()
                print("======= 檢舉按鈕被按下")
                print("Alert Type: \(String(describing: viewModel.alertType))")
            }, label: {
                Label("檢舉", systemImage: "exclamationmark.triangle")
                    .foregroundColor(.red)
            })

            Button(action: {
                onBlock()
                print("Alert Type: \(String(describing: viewModel.alertType))")
            }, label: {
                Label("封鎖", systemImage: "hand.raised.fill")
                    .foregroundColor(.red)
            })

            Button(action: {
                onDelete()
                print("Alert Type: \(String(describing: viewModel.alertType))")
            }, label: {
                Label("刪除好友", systemImage: "trash")
                    .foregroundColor(.red)
            })
        } label: {
            Image(systemName: "exclamationmark.square.fill")
                .foregroundColor(.gray)
                .padding(8)
        }
    }
}
