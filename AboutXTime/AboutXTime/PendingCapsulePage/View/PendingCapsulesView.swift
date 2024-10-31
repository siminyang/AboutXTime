//
//  PendingCapsulesView.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/15.
//

import Foundation
import SwiftUI
import FirebaseCrashlyticsSwift

struct PendingCapsulesView: View {
    let capsules: [Capsule]
    let colors: [Color] = [.green, .yellow, .orange, .red, .blue, .purple, .pink]
    let imageNames = (1...18).map { "planet\($0)" }

    @State private var capsulePositions: [CGPoint] = []
    @State private var capsuleSizes: [CGFloat] = []
    @State private var capsuleImageNames: [String] = []
    @State private var showReminder = true

    var body: some View {
        GeometryReader { geometry in
            ZStack {

                Image("background11")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width * 1.5, height: geometry.size.height * 1.5)
                    .edgesIgnoringSafeArea(.all)

                if filteredCapsules.isEmpty {
                    Text("你的時空膠囊還空空的呢～📦\n \n快來創建一個，讓未來的你有驚喜可以開啟吧！💌")
                        .font(.caption)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                        .cornerRadius(10)
                        .frame(width: geometry.size.width * 0.8)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)

                } else {
                    ScrollView(.horizontal) {
                        ZStack {
                            ForEach(filteredCapsules) { capsule in
                                let index = filteredCapsules.firstIndex(where: { $0.id == capsule.id }) ?? 0
                                let bubbleSize =
                                capsuleSizes.count > index ? capsuleSizes[index] : CGFloat.random(in: 100...150)
                                let imageName = capsuleImageNames.count > index ? capsuleImageNames[index] : "planet1"

                                if capsulePositions.count > index {
                                    CapsuleBubbleView(capsule: capsule, size: bubbleSize,
                                                      color: colors[index % colors.count],
                                                      imageName: imageName)
                                        .position(capsulePositions[index])
                                        .frame(minWidth: geometry.size.width * 3, minHeight: geometry.size.height)
                                }
                            }
                        }
                        .onAppear {
                            if capsulePositions.isEmpty {
                                generateNonOverlappingPositions(for: filteredCapsules, in: geometry)
                            }
                            if capsuleImageNames.isEmpty {
                                capsuleImageNames = filteredCapsules.map { _ in
                                    imageNames.randomElement()!
                                }
                            }
                        }
                    }
                }

                Text("左右滑動尋找你的專屬膠囊✨\n目前只顯示最近的十顆膠囊喔🪐")
                    .font(.caption)
                    .foregroundColor(.white)
                    .lineSpacing(5)
                    .padding(8)
                    .background(Color.white.opacity(0.1))
                    .position(x: geometry.size.width / 2, y: geometry.size.height * 0.05)
                    .opacity(showReminder ? 1 : 0)
                    .animation(.easeInOut, value: showReminder)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                        showReminder = false
                }
            }
        }
    }

    func getFilteredCapsules() -> [Capsule] {
        return filteredCapsules
    }

    private var filteredCapsules: [Capsule] {
        return capsules
            .filter { capsule in
                capsule.recipients.contains { $0.status == 0 }
            }
            .sorted { $0.openDate < $1.openDate }
            .prefix(10)
            .map { $0 }
    }

    private func generateNonOverlappingPositions(for capsules: [Capsule], in geometry: GeometryProxy) {
        capsulePositions.removeAll()
        capsuleSizes.removeAll()

        let safeAreaInsets = geometry.safeAreaInsets
        let minX = safeAreaInsets.leading + 100
        let maxX = geometry.size.width * 2 - safeAreaInsets.trailing
        let minY = safeAreaInsets.top
        let maxY = geometry.size.height - safeAreaInsets.bottom - 150

        for index in capsules.indices {
            var bubbleSize = CGFloat.random(in: 100...150)
            var newPosition: CGPoint
            var positionIsValid = false
            var attempts = 0

            repeat {
                attempts += 1

                if index == 0 {
                    let xPosition = geometry.size.width / 3
                    newPosition = CGPoint(
                        x: CGFloat.random(in: (xPosition - bubbleSize / 2)...(xPosition + bubbleSize / 2)),
                        y: CGFloat.random(in: (minY + bubbleSize / 2)...(maxY * 1.5 - bubbleSize))
                    )

                } else {
                    newPosition = CGPoint(
                        x: CGFloat.random(in: (minX + bubbleSize / 2)...(maxX - bubbleSize / 2)),
                        y: CGFloat.random(in: (minY + bubbleSize / 2)...(maxY * 1.5 - bubbleSize))
                    )
                }

                positionIsValid = !capsulePositions.contains(where: { existingPosition in
                    existingPosition.distance(to: newPosition) < bubbleSize
                })

                if attempts > 100 {
                    bubbleSize *= 0.9
                }

            } while !positionIsValid && attempts < 1000

            if positionIsValid {
                capsulePositions.append(newPosition)
                capsuleSizes.append(bubbleSize)
            } else {
                print("Could not find a non-overlapping position after 1000 attempts.")
            }
        }
    }
}
