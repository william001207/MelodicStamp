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
            let isMetadataLoaded = item.editableMetadata.state.isLoaded
            let isMetadataModified = item.editableMetadata.isModified
            
            VStack(alignment: .leading) {
                HStack {
                    if isMetadataModified {
                        Image(systemSymbol: .pencilLine)
                            .bold()
                            .foregroundStyle(.tint)
                    }
                    
                    if isMetadataLoaded {
                        MarqueeScrollView(animate: false) {
                            MusicTitle(item: item)
                        }
                    } else {
                        Text("Loading…")
                            .foregroundStyle(.placeholder)
                    }
                }
                .font(.title3)
                .transition(.blurReplace)
                .animation(.default, value: isMetadataLoaded)
                .animation(.default, value: isMetadataModified)
                
                Text(item.url.lastPathComponent)
                    .font(.caption)
                    .foregroundStyle(.placeholder)
            }
            
            Spacer()
            
            AliveButton {
                player.play(item: item)
            } label: {
                ZStack {
                    if isMetadataLoaded {
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
                        .clipShape(.rect(cornerRadius: 6))
                    }
                    
                    if isHovering {
                        Image(systemSymbol: isMetadataLoaded ? .playFill : .playSlashFill)
                            .font(.title3)
                            .foregroundStyle(.white)
                            .contentTransition(.symbolEffect(.replace))
                    }
                }
                .frame(width: 40, height: 40)
            }
        }
        .padding(.vertical, 10)
        .padding(.leading, 12)
        .padding(.trailing, 6)
        .onHover { hover in
            withAnimation(.default.speed(5)) {
                isHovering = hover
            }
        }
    }
}
