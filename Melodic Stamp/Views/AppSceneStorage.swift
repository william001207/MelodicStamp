//
//  AppSceneStorage.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/12.
//

import SwiftUI

enum AppSceneStorage: String, Hashable, Equatable, CaseIterable, Identifiable, Codable {
    // MARK: Content View (Global Scene Scope)

    case playlistTracks
    case metadataTracks

    // MARK: Playlist View

    case playlistViewPlaybackMode
    case playlistViewPlaybackPosition
    case playlistViewPlaybackVolume

    var id: String { rawValue }

    func callAsFunction() -> String { rawValue }
}
