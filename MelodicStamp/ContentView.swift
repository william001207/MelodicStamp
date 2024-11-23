//
//  ContentView.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/23.
//

import SwiftUI

struct ContentView: View {
    @Namespace private var namespace
    
    @State private var player: PlayerModel = .init()
    @State private var windowStyle: MelodicStampWindowStyle = .main
    
    var body: some View {
        Group {
            switch windowStyle {
            case .main:
                MainView(player: player)
            case .miniPlayer:
                MiniPlayer(player: player, namespace: namespace)
                    .padding(8)
                    .background {
                        VisualEffectView(material: .popover, blendingMode: .behindWindow)
                    }
                    .padding(.bottom, -32)
                    .edgesIgnoringSafeArea(.all)
                    .frame(minWidth: 500, idealWidth: 500)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .environment(\.melodicStampWindowStyle, windowStyle)
        .environment(\.changeMelodicStampWindowStyle) { windowStyle in
            self.windowStyle = windowStyle
        }
    }
}
