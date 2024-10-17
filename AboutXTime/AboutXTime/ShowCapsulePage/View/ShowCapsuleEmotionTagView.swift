//
//  ShowCapsuleEmotionTagView.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/17.
//

import Foundation
import SwiftUI

struct ShowCapsuleEmotionTagView: View {
    let emotionTagLabels: [String]

    var body: some View {
        if !emotionTagLabels.isEmpty {
            HStack {
                ForEach(emotionTagLabels, id: \.self) { emotionTag in
                    Text(emotionTag)
                        .padding(10)
                        .background(.white.opacity(0.1))
                        .cornerRadius(8)
                        .font(.body)
                        .foregroundColor(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(STColor.CC2.color.opacity(0.5), lineWidth: 0.5)
                        )
                        .frame(height: 20)
                }
            }
            .padding(.horizontal)
        }
    }
}
