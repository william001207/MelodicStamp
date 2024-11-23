//
//  FloatingPlayerView.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/22.
//

import SwiftUI

struct FloatingPlayerView: View {
    @State var model: FloatingWindowsModel
    
    @Namespace private var namespace
    
    @State var onHover: Bool = false
    
    var body: some View {
        ZStack {
            
            VisualEffectView(material: .popover, blendingMode: .behindWindow)
            
            Player(namespace: namespace)
                .background(.clear)
            
        }
        .frame(width: 800, height: 100)
        .clipShape(.rect(cornerRadius: 25))
    }
}
