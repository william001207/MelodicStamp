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
    var item: PlayableItem?

    var body: some View {
        if let item {
            HStack(spacing: 12) {
                if mode.hasTitle {
                    var title: String?
                    
                    Group {
                        if let title, !title.isEmpty {
                            Text(title)
                        } else {
                            Text(Self.fallbackTitle(for: item))
                        }
                    }
                    .bold()
                    .task { @MainActor in
                        title = item.metadata[extracting: \.title]?.initial
                    }
                }

                if mode.hasArtists {
                    var artist: String?
                    
                    Group {
                        if let artist {
                            HStack(spacing: 4) {
                                let artists = Metadata.splitArtists(from: artist)
                                ForEach(Array(artists.enumerated()), id: \.offset) {
                                    offset, composer in
                                    if offset > 0 {
                                        let separator = String(localized: .init(
                                            "MusicTitle: (Separator) Artists",
                                            defaultValue: "·",
                                            comment: "The separator between artists in a regular title"
                                        ))
                                        Text(separator)
                                            .foregroundStyle(.placeholder)
                                    }
                                    
                                    Text(composer)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .task { @MainActor in
                        artist = item.metadata[extracting: \.artist]?.initial
                    }
                }
            }
        } else {
            Text("Nothing to Play")
                .bold()
                .foregroundStyle(.placeholder)
        }
    }

    nonisolated static func fallbackTitle(for item: PlayableItem) -> String {
        Metadata.fallbackTitle(url: item.url)
    }

    @MainActor static func stringifiedTitle(
        mode: DisplayMode = .comprehensive, for item: PlayableItem, separator: String = " "
    ) -> String {
        var components: [String] = []
        if mode.hasTitle {
            if let title = item.metadata[extracting: \.title]?.initial {
                components.append(title)
            } else {
                components.append(fallbackTitle(for: item))
            }
        }

        if mode.hasArtists {
            if let artist = item.metadata[extracting: \.artist]?.initial {
                let separator = String(localized: .init(
                    "MusicTitle : (Separator) Stringified Artists",
                    defaultValue: ", ",
                    comment: "The separator between artists in a stringified title"
                ))
                components.append(Metadata.splitArtists(from: artist).joined(separator: separator))
            }
        }
        return components.joined(separator: separator)
    }
}
