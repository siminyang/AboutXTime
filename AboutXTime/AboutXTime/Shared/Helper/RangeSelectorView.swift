//
//  RangeSelectorView.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/14.
//

import SwiftUI

struct RangeSelectorView: View {
    @Binding var radius: Int

    var body: some View {
        VStack {

            Slider(value: Binding(get: {
                Double(radius)
            }, set: { newValue in
                radius = Int(newValue)
            }), in: 0...10, step: 1)
            .accentColor(.black) // 更改滑塊的颜色
            .tint(STColor.CC2.color)
            .padding(.bottom, 5)

            Text("限制開啟範圍須在： \(radius) 公里內")
                .font(.caption)
        }
    }
}
