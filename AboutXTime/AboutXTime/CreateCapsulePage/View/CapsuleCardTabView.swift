//
//  CapsuleCardTAbView.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/13.
//

import SwiftUI
import NVActivityIndicatorView

struct CapsuleCardTabView: View {
    @ObservedObject var viewModel = CardViewModel()
    @State private var showAlert = false
    @State private var isUploading = false

    var body: some View {
        ZStack {
            VStack {
                TabView(selection: $viewModel.currentIndex) {

                    CardView {
                        TextCardView(text: $viewModel.text,
                                     fromWhom: $viewModel.fromWhom,
                                     toWhom: $viewModel.toWhom,
                                     viewModel: viewModel)
                    }
                    .tag(0)

                    CardView {
                        ImagePickerCardView(viewModel: viewModel)
                    }
                    .tag(1)

                    CardView {
                        AudioPickerCardView(localAudioUrl: $viewModel.localAudioUrl)
                    }
                    .tag(2)

                    CardView {
                        VideoPickerCardView(localVideoUrl: $viewModel.localVideoUrl)
                    }
                    .tag(3)

                    CardView {
                        SettingsCardView(
                            isAnonymous: $viewModel.isAnonymous,
                            isLocationLocked: $viewModel.isLocationLocked,
                            openDate: $viewModel.openDate,
                            recipient: $viewModel.recipient,
                            currentLatitude: $viewModel.currentLatitude,
                            currentLongitude: $viewModel.currentLongitude,
                            currentRadius: Binding(
                                get: { viewModel.currentRadius ?? 0 },
                                set: { viewModel.currentRadius = $0 }
                            ),
                            capsuleId: viewModel.capsuleId
                        )
                    }
                    .tag(4)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))

                Spacer()

                Button(action: {
                    isUploading = true
                    viewModel.submitCapsule { success in
                        isUploading = false
                        if !success {
                            showAlert = true
                        }
                    }
                }) {
                    Text("寄往未來")
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(STColor.C1.color.opacity(0.5), lineWidth: 2)
                        )
                }
                .opacity(viewModel.currentIndex == 4 && !isUploading ? 1 : 0)
                .disabled(viewModel.currentIndex != 4 || isUploading)
                .animation(.easeInOut, value: viewModel.currentIndex)
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("錯誤"),
                        message: Text(viewModel.errorMessage ?? ""),
                        dismissButton: .default(Text("確定"), action: {
                            viewModel.errorMessage = nil
                        })
                    )
                }
            }
            .padding()
            .onReceive(NotificationCenter.default.publisher(for: .showAlert)) { _ in
                self.showAlert = true
            }
            .background(.black)
            .ignoresSafeArea(.keyboard)

            if isUploading {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .transition(.opacity)
            }

            ActivityIndicatorView(type: .orbit, color: STColor.CC2.uiColor, padding: nil, isAnimating: $isUploading)
                .frame(width: 80, height: 80)
                .opacity(isUploading ? 1 : 0)
        }
    }

    private func navigateToTab(index: Int) {
        guard let window = UIApplication.shared.windows.first,
              let tabBarController = window.rootViewController as? UITabBarController else {
            return
        }
        tabBarController.selectedIndex = index
    }
}
