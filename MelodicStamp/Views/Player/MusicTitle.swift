//
//  MusicTitle.swift
//  Playground
//
//  Created by KrLite on 2024/11/17.
//

import SwiftUI

struct MusicTitle: View {
    @State var model: PlayerModel = .shared
    
    var body: some View {
        if let metadata = model.currentMetadata {
            HStack(spacing: 12) {
                Group {
                    if let title = metadata.title {
                        Text(title)
                    } else if let url = model.currentURL {
                        Text(url.lastPathComponent)
                    } else {
                        Text("Unknown Music")
                            .foregroundStyle(.placeholder)
                    }
                }
                .bold()
                
                if let artist = metadata.artist {
                    HStack(spacing: 4) {
                        let artists = splitArtists(from: artist)
                        ForEach(Array(artists.enumerated()), id: \.offset) { offset, composer in
                            if offset > 0 {
                                Text("·")
                                    .foregroundStyle(.placeholder)
                            }
                            
                            Text(composer)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        } else {
            Text("Nothing to Play")
                .bold()
                .foregroundStyle(.placeholder)
        }
    }
    
    private func splitArtists(from artist: String) -> [Substring] {
        artist.split(separator: /[\/,]\s*/)
    }
}
