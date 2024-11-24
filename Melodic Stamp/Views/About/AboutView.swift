//
//  AboutView.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/24.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .padding(20)
            .padding(.top, 16)
            .background {
                VisualEffectView(material: .titlebar, blendingMode: .behindWindow)
            }
            .edgesIgnoringSafeArea(.all)
            .padding(.bottom, -28)
            .fixedSize()
    }
}

#Preview {
    AboutView()
}
