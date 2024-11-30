//
//  PlaylistItemView.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/23.
//

import SwiftUI

struct PlaylistItemView: View {
    @Bindable var player: PlayerModel
    
    var item: PlaylistItem
    var isSelected: Bool
    
    @State private var isHovering: Bool = false
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading) {
                MarqueeScrollView(animate: false) {
                    MusicTitle(item: item)
                        .font(.title3)
                }
                
                Text(item.url.lastPathComponent)
                    .font(.caption)
                    .foregroundStyle(.placeholder)
            }
            
            Spacer()
            
            AliveButton {
                player.play(item: item)
            } label: {
                ZStack {
                    Group {
                        let values = item.editableMetadata[extracting: \.coverImages]
                        
                        MusicCover(cornerRadius: 0, coverImages: values.current)
                            .frame(maxWidth: .infinity)
                            .overlay {
                                if isHovering {
                                    Color.black
                                        .opacity(0.35)
                                        .blendMode(.darken)
                                }
                            }
                    }
                    .clipShape(.rect(cornerRadius: 8))
                    
                    if isHovering {
                        Image(systemSymbol: .playFill)
                            .font(.title3)
                            .foregroundStyle(.white)
                    }
                }
                .frame(width: 32, height: 32)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .onHover { hover in
            withAnimation(.default.speed(5)) {
                isHovering = hover
            }
        }
    }
}
