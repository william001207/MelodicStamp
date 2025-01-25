//
//  TrackPreview.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/25.
//

import SwiftUI

struct TrackPreview: View {
    var track: Track

    var body: some View {
        HStack(spacing: 12) {
            Group {
                if let thumbnail = track.metadata.thumbnail {
                    MusicCover(images: [thumbnail], cornerRadius: 2)
                } else {
                    MusicCover(cornerRadius: 2)
                }
            }
            .frame(width: 50)

            VStack(alignment: .leading) {
                MusicTitle(mode: .title, track: track)
                    .font(.callout)

                MusicTitle(mode: .artists, track: track)
                    .font(.caption)
            }
        }
    }
}

#if DEBUG
    #Preview {
        TrackPreview(track: SampleEnvironmentsPreviewModifier.sampleTrack)
            .border(.blue)
            .padding(100)
    }
#endif
