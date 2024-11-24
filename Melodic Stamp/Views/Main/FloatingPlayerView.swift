//
//  FloatingPlayerView.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/22.
//

import SwiftUI

struct FloatingPlayerView: View {
    @Namespace private var namespace
    
    @Bindable var floatingWindows: FloatingWindowsModel
    @Bindable var player: PlayerModel
    
    var body: some View {
        ZStack {
            VisualEffectView(material: .popover, blendingMode: .behindWindow)
            
            Player(player: player, namespace: namespace)
        }
        .frame(width: 800, height: 100)
        .clipShape(.rect(cornerRadius: 25))
    }
}
