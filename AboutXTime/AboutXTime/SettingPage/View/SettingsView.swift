//
//  SettingsView.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/29.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        VStack {
            List {
                Button(action: {
                    viewModel.showLogoutAlert = true
                }, label: {
                    Text("登出")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                })
                .buttonStyle(.plain)
                .listRowBackground(Color.black)
                .alert(isPresented: $viewModel.showLogoutAlert) {
                    Alert(
                        title: Text("登出"),
                        message: Text("確定要登出嗎？"),
                        primaryButton: .destructive(Text("是")) {
                            viewModel.logout()
                        },
                        secondaryButton: .cancel(Text("否"))
                    )
                }

                Button(action: {
                    viewModel.showDeleteAlert = true
                }, label: {
                    Text("刪除帳戶")
                        .frame(maxWidth: .infinity, alignment: .center)
                })
                .listRowBackground(Color.black)
                .foregroundColor(.red)
                .alert(isPresented: $viewModel.showDeleteAlert) {
                    Alert(
                        title: Text("刪除帳戶"),
                        message: Text("確定要永久刪除此帳戶嗎？所有資料將被清空。"),
                        primaryButton: .destructive(Text("是")) {
                            viewModel.deleteAccount()
                        },
                        secondaryButton: .cancel(Text("否"))
                    )
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.black)
            .disabled(viewModel.isProcessing)
        }
        .background(Color.black)
    }
}
