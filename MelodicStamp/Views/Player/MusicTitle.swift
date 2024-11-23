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
    var metadata: AudioMetadata?
    var url: URL?
    
    var body: some View {
        if let metadata {
            HStack(spacing: 12) {
                if mode.hasTitle {
                    Group {
                        if let title = metadata.title {
                            Text(title)
                        } else if let url {
                            Text(url.lastPathComponent)
                        } else {
                            Text("Unknown Music")
                                .foregroundStyle(.placeholder)
                        }
                    }
                    .bold()
                }
                
                if mode.hasArtists, let artist = metadata.artist {
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
