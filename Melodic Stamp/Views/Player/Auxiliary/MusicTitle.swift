//
//  MusicTitle.swift
//  Playground
//
//  Created by KrLite on 2024/11/17.
//

import CSFBAudioEngine
import SwiftUI

struct MusicTitleDisplayMode: OptionSet {
    let rawValue: Int

    static let title = MusicTitleDisplayMode(rawValue: 1 << 0)
    static let artists = MusicTitleDisplayMode(rawValue: 1 << 1)

    static var all: MusicTitleDisplayMode {
        [.title, .artists]
    }
}

struct MusicTitle: View {
    var mode: MusicTitleDisplayMode = .all
    var track: Track?

    var body: some View {
        if let track {
            HStack(spacing: 12) {
                if mode.contains(.title) {
                    Group {
                        if let title = track.metadata[extracting: \.title]?
                            .initial, !title.isEmpty {
                            Text(title)
                        } else {
                            Text(Self.fallbackTitle(for: track))
                        }
                    }
                    .bold()
                }

                if mode.contains(.artists) {
                    if let artists = track.metadata[extracting: \.artist]?.initial?.splittingArtists {
                        HStack(spacing: 4) {
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
            }
        } else {
            Text("Nothing to Play")
                .bold()
                .foregroundStyle(.placeholder)
        }
    }

    static func fallbackTitle(for track: Track) -> String {
        track.url.lastPathComponentRemovingExtension
    }

    static func stringifiedTitle(
        mode: MusicTitleDisplayMode = .all, for track: Track, separator: String = " "
    ) -> String {
        var components: [String] = []
        if mode.contains(.title) {
            if let title = track.metadata[extracting: \.title]?.initial {
                components.append(title)
            } else {
                components.append(fallbackTitle(for: track))
            }
        }

        if mode.contains(.artists) {
            if let artists = track.metadata[extracting: \.artist]?.initial?.splittingArtists {
                let separator = String(localized: .init(
                    "MusicTitle : (Separator) Stringified Artists",
                    defaultValue: ", ",
                    comment: "The separator between artists in a stringified title"
                ))
                components.append(artists.joined(separator: separator))
            }
        }
        return components.joined(separator: separator)
    }
}
