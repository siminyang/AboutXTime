//
//  ShowCapsuleTextView.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/17.
//

import Foundation
import SwiftUI

struct ShowCapsuleTextView: View {
    let text: String

    var body: some View {
        if !text.isEmpty {
            Text(text)
                .font(.body)
                .padding(.horizontal)
                .accessibilityLabel("Text content")
                .foregroundColor(.white)
        }
    }
}
