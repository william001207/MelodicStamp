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
            .padding()
            .background {
                VisualEffectView(material: .fullScreenUI, blendingMode: .behindWindow)
            }
            .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    AboutView()
}
