//
//  FloatingPlayerView.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/22.
//

import SwiftUI

struct FloatingPlayerView: View {
    @Bindable var floatingWindowsModel: FloatingWindowsModel
    @Bindable var playerModel: PlayerModel
    
    @Namespace private var namespace
    
    var body: some View {
        ZStack {
            VisualEffectView(material: .popover, blendingMode: .behindWindow)
            
            Player(model: playerModel, namespace: namespace)
        }
        .frame(width: 800, height: 100)
        .clipShape(.rect(cornerRadius: 25))
    }
}
