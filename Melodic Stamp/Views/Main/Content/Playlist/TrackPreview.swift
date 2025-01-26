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
            .overlay(alignment: .topLeading) {
                if let duration = track.metadata.properties.duration.map(Duration.init) {
                    DurationText(duration: duration)
                        .font(.system(size: 7))
                        .padding(.horizontal, 2)
                        .foregroundStyle(.white)
                        .shadow(color: .black, radius: 2)
                }
            }

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
