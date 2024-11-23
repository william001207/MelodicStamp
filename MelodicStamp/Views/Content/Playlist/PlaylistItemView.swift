//
//  PlaylistItemView.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/23.
//

import SwiftUI

struct PlaylistItemView: View {
    @State var player: PlayerModel
    
    var item: PlaylistItem
    var isSelected: Bool
    var action: () -> Void
    
    @State private var isHovering: Bool = false
    
    var body: some View {
        AliveButton(scaleFactor: 0.975) {
            action()
        } label: {
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    MusicTitle(metadata: item.metadata, url: item.url)
                        .font(.title3)
                    
                    Text(item.url.lastPathComponent)
                        .font(.caption)
                        .foregroundStyle(.placeholder)
                }
                
                Spacer()
                
                AliveButton {
                    player.play(item)
                } label: {
                    ZStack {
                        Group {
                            if let image = item.metadata.attachedPictures.first?.image {
                                Image(nsImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .clipShape(.rect(cornerRadius: 4))
                        .overlay {
                            if isHovering {
                                Color.black.opacity(0.35)
                                
                                Image(systemSymbol: .playFill)
                                    .font(.title3)
                            }
                        }
                    }
                    .frame(width: 32, height: 32)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
        }
        .frame(height: 65)
        .onHover { hover in
            withAnimation(.default.speed(5)) {
                isHovering = hover
            }
        }
    }
}
