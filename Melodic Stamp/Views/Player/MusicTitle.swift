//
//  MusicTitle.swift
//  Playground
//
//  Created by KrLite on 2024/11/17.
//

import CSFBAudioEngine
import SwiftUI

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
                        let values = item.editableMetadata[extracting: \.title]
                        if let title = values.current, !title.isEmpty {
                            Text(title)
                        } else {
                            Text(item.url.lastPathComponent.dropLast(item.url.pathExtension.count + 1))
                        }
                    }
                    .bold()
                }

                if mode.hasArtists {
                    let values = item.editableMetadata[extracting: \.artist]

                    if let artist = values.current {
                        HStack(spacing: 4) {
                            let artists = PlayerModel.splitArtists(from: artist)
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
            }
        } else {
            Text("Nothing to Play")
                .bold()
                .foregroundStyle(.placeholder)
        }
    }
}
