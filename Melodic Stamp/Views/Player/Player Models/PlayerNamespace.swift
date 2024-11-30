//
//  PlayerNamespace.swift
//  MelodicStamp
//
//  Created by 屈志健 on 2024/11/20.
//


import SwiftUI

enum PlayerNamespace: String, Identifiable, Hashable, Equatable {
    case title
    case progressBar
    case volumeBar
    
    case playPauseButton
    case previousSongButton
    case nextSongButton
    case volumeButton
    case playlistButton

    case timeText
    case durationText
    
    case playbackModeButton
    case expandShrinkButton
    
    var id: Self { self }
}
