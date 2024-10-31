//
//  CapsuleBubbleView.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/15.
//

import SwiftUI

struct CapsuleBubbleView: View {
    let capsule: Capsule
    let size: CGFloat
    let color: Color
    let imageName: String
    @State private var offset = CGSize.zero
    @State private var showCapsulePage = false
    @State private var timeRemaining = ""
    @State private var progress: CGFloat = 0.0
    @State private var canOpen = false
    @State private var animateProgress = true
    @State private var progressColor: Color = .gray
    @State private var showMapPage = false

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            if capsule.recipients.contains(where: { $0.status == 0 }) {

                // 外圍進度圓環
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 2)
                    .frame(width: size + 5, height: size + 5)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(progressColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: size + 5, height: size + 5)
                    .animation(animateProgress ? .easeInOut(duration: 2) : .none, value: progress)

                // 泡泡的內部
                Circle()
                    .fill(
                        RadialGradient(gradient: Gradient(
                            colors: [color.opacity(0.7),
                                     color.opacity(0.2),
                                     Color.clear]),
                                       center: .center,
                                       startRadius: size / 4,
                                       endRadius: size / 1.5)
                    )
                    .frame(width: size + 20, height: size + 20)
                    .blur(radius: 10)
                    .opacity(canOpen ? 0.6 : 0.8)

                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size * 0.9, height: size * 0.9)
                    .foregroundColor(color)
                    .opacity(canOpen ? 1 : 0.3)

                Text(canOpen ? "開啟" : timeRemaining)
                    .font(canOpen ? .headline : .custom("DINCondensed-Bold", size: size * 0.2))
                                    .foregroundColor(.white)
                                    .padding(5)
                                    .opacity(1)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    self.offset = CGSize(width: CGFloat.random(in: -20...20), height: CGFloat.random(in: -20...20))
                }
            }
            updateProgress(initial: true)
        }
        .frame(width: size + 20, height: size + 20)
        .offset(offset)

        .onReceive(timer) { _ in
            updateProgress(initial: false)
        }
        .background(
            NavigationLink(
                destination: ShowCapsulePageRepresentable(capsule: capsule,
                                                          isPresented: $showCapsulePage).ignoresSafeArea(.all),
                isActive: $showCapsulePage
            ) {
                EmptyView()
            }
        )
        .onTapGesture {
            if canOpen {
                let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                impactFeedback.impactOccurred()

                if capsule.isLocationLocked {
                    showMapPage = true
                } else {
                    showCapsulePage = true
                }
            }
        }
        .background(
            NavigationLink(destination: MapViewControllerRepresentable(capsule: capsule).ignoresSafeArea(.all),
                           isActive: $showMapPage) {
                               EmptyView()
                           }
        )
    }

    private func updateProgress(initial: Bool) {
        let now = Date()
        let remainingSeconds = max(0, Int(capsule.openDate.timeIntervalSince(now)))
        let totalDuration = capsule.openDate.timeIntervalSince(capsule.createdDate)

        if remainingSeconds > 0 {

            let hours = remainingSeconds / 3600
            let minutes = (remainingSeconds % 3600) / 60
            let seconds = remainingSeconds % 60
            timeRemaining = String(format: "%02d:%02d:%02d", hours, minutes, seconds)

            let newProgress = min(1, max(0, CGFloat(remainingSeconds) / CGFloat(totalDuration)))
            progressColor = STColor.CC2.color.opacity(0.3) // 正在跑

            if initial {
                withAnimation(.easeInOut(duration: 2)) {
                    progress = 1 - newProgress
                }
                animateProgress = false  // 設置動畫已完成狀態，後續不再動畫

            } else {
                // 無動畫的進度更新
                progress = 1 - newProgress
            }

            canOpen = false

        } else {
            timeRemaining = "00:00:00"
            progress = 1.0
            progressColor = STColor.CC1.color.opacity(0.3)  // 時間到
            canOpen = true
        }
    }
}
