//
//  Defaults+Extensions.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/5.
//

import Defaults
import Foundation
import SwiftUI

extension Defaults.Keys {
    // MARK: UI

    static let dynamicTitleBar: Key<Defaults.DynamicTitleBar> = .init(
        "dynamicTitleBar",
        default: .whilePlaying
    )

    // MARK: Behavior

    static let defaultPlaybackMode: Key<PlaybackMode> = .init(
        "defaultPlaybackMode",
        default: .sequential
    )

    static let memorizesPlaybackModes: Key<Bool> = .init(
        "memorizesPlaybackModes",
        default: true
    )

    static let memorizesPlaylists: Key<Bool> = .init(
        "memorizesPlaylists",
        default: true
    )

    static let memorizesPlaybackPositions: Key<Bool> = .init(
        "memorizesPlaybackPositions",
        default: true
    )

    static let memorizesPlaybackVolumes: Key<Bool> = .init(
        "memorizesPlaybackVolumes",
        default: true
    )

    // MARK: Window Backgrounds

    static let mainWindowBackgroundStyle: Key<Defaults.MainWindowBackgroundStyle> = .init(
        "mainWindowBackgroundStyle",
        default: .vibrant
    )

    static let miniPlayerBackgroundStyle: Key<Defaults.MiniPlayerBackgroundStyle> = .init(
        "miniPlayerBackgroundStyle",
        default: .chroma
    )

    // MARK: Gradient

    static let gradientDynamics: Key<Defaults.GradientDynamics> = .init(
        "gradientDynamics",
        default: .ternary
    )

    static let gradientResolution: Key<Defaults.GradientResolution> = .init(
        "gradientResolution",
        default: .clamp(0.8)
    )

    static let gradientFPS: Key<Defaults.GradientFPS> = .init(
        "gradientFPS",
        default: .clamp(120)
    )

    // MARK: Lyrics

    static let isLyricsFadingEffectEnabled: Key<Bool> = .init(
        "isLyricsFadingEffectEnabled",
        default: true
    )

    static let lyricsMaxWidth: Key<Defaults.LyricsMaxWidth> = .init(
        "lyricsMaxWidth",
        default: .clamp(1024.0)
    )

    static let lyricsAttachments: Key<LyricsAttachments> = .init(
        "lyricsAttachments",
        default: .all
    )

    static let lyricsTypeSizes: Key<ClosedRange<DynamicTypeSize>> = .init(
        "lyricsTypeSizes",
        default: .small...(.xxLarge)
    )

    static let lyricsTypeSize: Key<DynamicTypeSize> = .init(
        "lyricsTypeSize",
        default: .large
    )

    // MARK: Performance

    static let hidesInspectorInBackground: Key<Bool> = .init(
        "hidesInspectorInBackground",
        default: false
    )

    static let hidesLyricsInBackground: Key<Bool> = .init(
        "hidesLyricsInBackground",
        default: false
    )
}

extension Defaults {
    static var canApplicationRestore: Bool {
        Self[.memorizesPlaylists] || Self[.memorizesPlaybackModes] || Self[.memorizesPlaybackPositions] || Self[.memorizesPlaybackVolumes]
    }
}
