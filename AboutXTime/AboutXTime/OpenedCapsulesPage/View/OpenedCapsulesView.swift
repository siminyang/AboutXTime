//
//  OpenedCapsulesView.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/18.
//

import Foundation
import SwiftUI

struct OpenedCapsulesView: View {
    @ObservedObject var viewModel: OpenedCapsulesViewModel

    @State private var selectedAge: Int?
    @State private var selectedCapsule: Capsule?
    @State private var showWeekSelection = false
    @State private var showCapsulePage = false
    @State private var capsulesForWeek: [Capsule] = []
    @State private var pushSearchView = false
    @State private var ageTextOpacity: Double = 0.0
    @State private var isVisible = true

    let totalWeeks = 52
    let maxAge = 80
    let circleRadiusStep: CGFloat = 1.5

    let userBirthDate: Date

    var userAge: Int {
        let calendar = Calendar.current
        let now = Date()
        let ageInYears = calendar.dateComponents([.year], from: userBirthDate, to: now).year ?? 0
        return min(ageInYears, maxAge)
    }

    var progress: Double {
        return Double(userAge) / Double(maxAge)
    }

    var body: some View {
        GeometryReader { geometry in
            let safeAreaInsets = geometry.safeAreaInsets
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            let centerX = safeAreaInsets.leading + 10
            let centerY = screenHeight / 2 - 125

            ZStack {
                VStack {
                    VStack(alignment: .leading) {
                        Text("生命進度：0～80歲\n你已經走過： \(Int(progress * 100))%")
                            .font(.headline)
                            .foregroundColor(STColor.CC2.color)
                            .padding(.leading)
                            .frame(height: 60)

                        Spacer()

                        ProgressView(value: progress)
                            .progressViewStyle(LinearProgressViewStyle(tint: STColor.CC2.color))
                            .padding(.horizontal)
                            .frame(height: 10)

                        HStack {
                            ForEach(0..<9) { index in
                                Text("\(index * 10)")
                                    .font(.caption2)
                                    .foregroundColor(STColor.CC2.color)
                                if index < 8 {
                                    Spacer()
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                    .background(.black)

                    ZStack {
                        Canvas { context, _  in
                            for age in 1...maxAge {
                                let radius = CGFloat(age) * circleRadiusStep
                                let hasOpenedCapsules = checkCapsulesForAge(age)
                                let circleColor = hasOpenedCapsules ?
                                STColor.CC2.color : (age <= userAge ?
                                                     STColor.CC2.color.opacity(0.2) : STColor.CC1.color)

                                context.stroke(
                                    Path { path in  // 繪製圓圈路徑
                                        path.addEllipse(in: CGRect(x: centerX + radius,
                                                                   y: centerY - radius,
                                                                   width: radius * 2,
                                                                   height: radius * 2))
                                    },
                                    with: .color(circleColor),
                                    lineWidth: 0.8
                                )
                            }
                        }
                        .frame(width: screenWidth, height: screenHeight)
                        .background(Color.black.edgesIgnoringSafeArea(.all))
                    }
                    .padding(.top, 20)
                }
                .background(.black)

                Text("點擊以繼續")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .opacity(isVisible ? 1.0 : 0.3)
                    .position(x: screenWidth / 2, y: screenHeight - 80)
                    .onAppear {
                        withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                            isVisible.toggle()
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        self.pushSearchView = true
                    }

                NavigationLink(
                    destination: SearchViewControllerRepresentable(
                        capsules: viewModel.capsules,
                        userBirthDate: userBirthDate
                    ), isActive: $pushSearchView
                ) {
                    EmptyView()
                }
            }
        }
    }

    func checkCapsulesForAge(_ age: Int) -> Bool {
        let calendar = Calendar.current
        return viewModel.capsules.contains { capsule in
            let ageAtOpen = calendar.dateComponents([.year], from: userBirthDate, to: capsule.openDate).year ?? 0
            return ageAtOpen == age && capsule.recipients.contains { $0.status == 1 }
        }
    }
}
