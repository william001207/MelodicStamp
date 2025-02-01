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

    static let motionLevel: Key<Defaults.MotionLevel> = .init(
        "motionLevel",
        default: .fancy
    )

    // MARK: Behaviors

    static let defaultPlaybackMode: Key<PlaybackMode> = .init(
        "defaultPlaybackMode",
        default: .sequential
    )

    static let asksForPlaylistInformation: Key<Bool> = .init(
        "asksForPlaylistInformation",
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

    static let gradientAnimateWithAudio: Key<Bool> = .init(
        "gradientAnimateWithAudio",
        default: true
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
        default: .clamp(512.0)
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
}
