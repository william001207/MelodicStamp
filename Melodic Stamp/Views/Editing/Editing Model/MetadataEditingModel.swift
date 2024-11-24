//
//  MetadataEditingModel.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/24.
//

import SwiftUI
import CSFBAudioEngine

struct MetadataType {
    typealias Title = String
    typealias TitleSortOrder = String
    
    typealias Artist = String
    typealias ArtistSortOrder = String
    
    typealias AlbumTitle = String
    typealias AlbumTitleSortOrder = String
    
    typealias AlbumArtist = String
    typealias AlbumArtistSortOrder = String
    
    typealias Composer = String
    typealias ComposerSortOrder = String
    
    typealias TrackNumber = Int
    typealias TrackTotal = Int
    
    typealias DiscNumber = Int
    typealias DiscTotal = Int
    
    typealias Genre = String
    typealias GenreSortOrder = String
    
    typealias BPM = Int
    typealias Comment = String
    typealias Grouping = String
    
    typealias IsCompilation = Bool
    
    typealias ISRC = String
    typealias Lyrics = String
    typealias MCN = String
    typealias MusicBrainzRecordingID = String
    typealias MusicBrainzReleaseID = String
    typealias Rating = String
    typealias ReleaseDate = String
    
    typealias ReplayGainAlbumGain = String
    typealias ReplayGainAlbumPeak = String
    typealias ReplayGainTrackGain = String
    typealias ReplayGainTrackPeak = String
    typealias ReplayGainReferenceLoudness = String
}

@Observable class MetadataEditingModel {
}
