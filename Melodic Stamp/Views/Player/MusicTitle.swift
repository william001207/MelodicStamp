//
//  MusicTitle.swift
//  Playground
//
//  Created by KrLite on 2024/11/17.
//

import SwiftUI
import CSFBAudioEngine

struct MusicTitle: View {
    enum DisplayMode {
        case comprehensive
        case title
        case artists
        
        var hasTitle: Bool {
            switch self {
            case .artists:
                false
            default:
                true
            }
        }
        
        var hasArtists: Bool {
            switch self {
            case .title:
                false
            default:
                true
            }
        }
    }
    
    var mode: DisplayMode = .comprehensive
    var item: PlaylistItem?
    
    var body: some View {
        if let item {
            HStack(spacing: 12) {
                if mode.hasTitle {
                    Group {
                        if let title = item.metadata.title, !title.isEmpty {
                            Text(title)
                        } else {
                            Text(item.url.lastPathComponent.dropLast(item.url.pathExtension.count + 1))
                        }
                    }
                    .bold()
                }
                
                if mode.hasArtists, let artist = item.metadata.artist {
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
