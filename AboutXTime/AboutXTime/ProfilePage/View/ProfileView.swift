//
//  ProfileView.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/24.
//

import Foundation
import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel: ProfileViewModel
    @AppStorage("userAvatar") private var userAvatar: String = "planet4"

    @State private var isEditingFriendName: Bool = false
    @State private var editingFriendID: String?
    @State private var newFriendName: String = ""
    @State private var isShowingCopyAlert = false

    @State private var showAlert = false
    @State private var selectedFriendId: String?
    @State private var alertType: AlertType = .none

    enum AlertType {
        case report, block, delete, none
    }

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
                        showCopyNotification()
                    }) {
                        HStack {
                            Text("ID: \(viewModel.userID)")
                                .font(.caption)
                                .foregroundColor(.gray)

                            Image(systemName: "doc.on.doc")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                        }
                    }
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
                                    VStack {
                                        Image(friend.avatar)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 60, height: 60)
                                            .clipShape(Circle())
                                            .shadow(radius: 5)
                                            .onTapGesture {
                                                viewModel.changeFriendAvatar(friendID: friend.id)
                                            }
                                            .padding()

                                        HStack {
                                            if editingFriendID == friend.id {
                                                TextField("Name", text: $newFriendName)
                                                    .font(.body)
                                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                                    .frame(width: 100)
                                                    .background(Color.white.opacity(0.2))
                                                    .onSubmit {
                                                        viewModel.updateFriendName(friendID: friend.id, newName: newFriendName)
                                                        editingFriendID = nil
                                                    }
                                            } else {
                                                Text(friend.fullName)
                                                    .font(.caption)
                                                    .foregroundColor(.white)
                                            }

                                            Button(action: {
                                                editingFriendID = friend.id
                                                newFriendName = friend.fullName
                                            }) {
                                                Image(systemName: "pencil")
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        .padding(.bottom, 30)

                                        Button(action: {
                                            UIPasteboard.general.string = friend.id
                                            showCopyNotification()
                                        }) {
                                            HStack {
                                                Text("ID: \(friend.id)")
                                                    .font(.system(size: 10))
                                                    .foregroundColor(.gray)
                                                    .multilineTextAlignment(.leading)

                                                Image(systemName: "doc.on.doc")
                                                    .foregroundColor(.gray)
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                    }
                                    .padding()
                                    .frame(width: 150, height: 250)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)

                                    Menu {
                                        Button(action: {
                                            print("======= 檢舉按鈕被按下")
                                            selectedFriendId = friend.id
                                            alertType = .report
                                            DispatchQueue.main.async {
                                                showAlert = true
                                            }
                                            print("Report Button Pressed: \(selectedFriendId ?? "No ID")")
                                            print("Alert Type: \(alertType)")
                                            print("Show Alert: \(showAlert)")
                                        }) {
                                            Label("檢舉", systemImage: "exclamationmark.triangle")
                                                .foregroundColor(.red)
                                        }

                                        Button(action: {
                                            selectedFriendId = friend.id
                                            alertType = .block
                                            DispatchQueue.main.async {
                                                showAlert = true
                                            }
                                        }) {
                                            Label("封鎖", systemImage: "hand.raised.fill")
                                                .foregroundColor(.red)
                                        }

                                        Button(action: {
                                            selectedFriendId = friend.id
                                            alertType = .delete
                                            DispatchQueue.main.async {
                                                showAlert = true
                                            }
                                        }) {
                                            Label("刪除好友", systemImage: "trash")
                                                .foregroundColor(.red)
                                        }
                                    } label: {
                                        Image(systemName: "exclamationmark.square.fill")
                                            .foregroundColor(.gray)
                                            .padding(8)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .frame(height: 250)
                    Spacer()
                }

                Spacer()
            }
            .padding()
            .alert(isPresented: Binding<Bool>(
                get: {
                    alertType != .none ||
                    viewModel.showReportConfirmation ||
                    viewModel.showBlockConfirmation ||
                    viewModel.showDeleteConfirmation ||
                    viewModel.showErrorAlert
                },
                set: { newValue in
                    if !newValue {
                        resetAlertStates()
                    }
                }
            )) {
                if alertType != .none {
                    return getAlert()
                } else if viewModel.showReportConfirmation {
                    return Alert(
                        title: Text("已向系統回報"),
                        message: Text("您的檢舉已經提交。"),
                        dismissButton: .default(Text("確定")) {
                            resetAlertStates()
                        }
                    )
                } else if viewModel.showBlockConfirmation {
                    return Alert(
                        title: Text("封鎖成功"),
                        message: Text("該用戶已被封鎖。"),
                        dismissButton: .default(Text("確定")) {
                            resetAlertStates()
                        }
                    )
                } else if viewModel.showDeleteConfirmation {
                    return Alert(
                        title: Text("好友已刪除"),
                        message: Text("該用戶已從您的好友列表中刪除。"),
                        dismissButton: .default(Text("確定")) {
                            resetAlertStates()
                        }
                    )
                } else if viewModel.showErrorAlert {
                    return Alert(
                        title: Text("操作失敗"),
                        message: Text("系統繁忙，請稍後再試。"),
                        dismissButton: .default(Text("確定"))
                    )
                } else {
                    return Alert(title: Text(""))
                }
            }

            if isShowingCopyAlert {
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

    // MARK: - Methods
    private func showCopyNotification() {
        withAnimation {
            isShowingCopyAlert = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation {
                isShowingCopyAlert = false
            }
        }
    }

    private func getAlert() -> Alert {
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
                    DispatchQueue.main.async {
                        viewModel.showReportConfirmation = true
                    }
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
                    DispatchQueue.main.async {
                        viewModel.showBlockConfirmation = true
                    }
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
                    DispatchQueue.main.async {
                        viewModel.showDeleteConfirmation = true
                    }
                },
                secondaryButton: .cancel()
            )
        case .none:
            return Alert(title: Text(""))
        }
    }

    private func resetAlertStates() {
        showAlert = false
        viewModel.showReportConfirmation = false
        viewModel.showBlockConfirmation = false
        viewModel.showDeleteConfirmation = false
        alertType = .none
    }
}
