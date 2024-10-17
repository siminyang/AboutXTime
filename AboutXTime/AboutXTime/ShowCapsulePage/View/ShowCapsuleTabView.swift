//
//  ShowCapsuleTabView.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/17.
//

import SwiftUI

struct ShowCapsuleTabView: View {
    var capsule: Capsule
    var onDismiss: (() -> Void)?
    @Binding var isPresented: Bool

    var body: some View {
        TabView {
            ForEach(capsule.content.indices, id: \.self) { index in
                let content = capsule.content[index]
                ShowCapsulePageView(capsule: capsule, content: content)
                    .tag(index)
                    .ignoresSafeArea(.all)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.clear)
            }
            .scrollContentBackground(.hidden)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        .ignoresSafeArea(.all)
        .background(.black)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
