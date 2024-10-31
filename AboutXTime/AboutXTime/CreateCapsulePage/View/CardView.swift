//
//  CardView.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/13.
//

import SwiftUI

// 紫卡
struct CardView<Content: View>: View {
    let content: () -> Content

    var body: some View {
        VStack {
            content()
                .font(.largeTitle)
                .frame(width: 320, height: 420)
                .background(.clear)
                .foregroundColor(.white)
                .cornerRadius(20)
                .padding()
                .shadow(radius: 50)
        }
        .background(
            STColor.CC1.color.opacity(0.2)
                .cornerRadius(20)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.white, lineWidth: 0.5)
        )
    }
}
