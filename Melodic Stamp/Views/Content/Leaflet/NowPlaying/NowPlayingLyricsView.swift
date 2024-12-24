//
//  NowPlayingLyricsView.swift
//  Melodic Stamp
//
//  Created by Xinshao_Air on 2024/12/24.
//

import SwiftUI

struct NowPlayingLyricsView: View {
    
    @Environment(PlayerModel.self) var player
    @Environment(LyricsModel.self) var lyrics

    @State private var canPushAnimation: Bool = true
    @State private var highlightedRange: Range<Int> = 0..<1
    
    var currentTime: TimeInterval

    var body: some View {
        VStack {
            DynamicScrollView(
                canPushAnimation: canPushAnimation,
                range: 0..<10,
                highlightedRange: highlightedRange,
                alignment: .center
            ) { index, isHighlighted in
                
            } indicators: {
                EmptyView()
            }
        }
        .border(.foreground, width: 5)
    }
}
