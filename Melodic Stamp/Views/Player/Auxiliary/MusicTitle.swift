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
    var track: Track?

    var body: some View {
        if let track {
            HStack(spacing: 12) {
                if mode.hasTitle {
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

                if mode.hasArtists {
                    if let artist = track.metadata[extracting: \.artist]?.initial {
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
            }
        } else {
            Text("Nothing to Play")
                .bold()
                .foregroundStyle(.placeholder)
        }
    }

    static func fallbackTitle(for track: Track) -> String {
        Metadata.fallbackTitle(url: track.url)
    }

    static func stringifiedTitle(
        mode: DisplayMode = .comprehensive, for track: Track, separator: String = " "
    ) -> String {
        var components: [String] = []
        if mode.hasTitle {
            if let title = track.metadata[extracting: \.title]?.initial {
                components.append(title)
            } else {
                components.append(fallbackTitle(for: track))
            }
        }

        if mode.hasArtists {
            if let artist = track.metadata[extracting: \.artist]?.initial {
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
