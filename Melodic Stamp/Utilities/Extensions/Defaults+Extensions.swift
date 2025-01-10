//
//  Defaults+Extensions.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/5.
//

import Defaults
import Foundation

extension Defaults.Keys {
    // MARK: UI

    static let isDynamicTitleBarEnabled: Key<Bool> = .init(
        "isDynamicTitleBarEnabled",
        default: true
    )

    // MARK: Behavior

    static let memorizesPlaylist: Key<Bool> = .init(
        "memorizesPlaylist",
        default: true
    )
    static let memorizesPlaybackPosition: Key<Bool> = .init(
        "memorizesPlaybackPosition",
        default: true
    )
    static let memorizesPlaybackVolume: Key<Bool> = .init(
        "memorizesPlaybackVolume",
        default: true
    )
    static let memorizesPlaybackMode: Key<Bool> = .init(
        "memorizesPlaybackMode",
        default: true
    )

    // MARK: Window Backgrounds

    static let mainWindowBackgroundStyle: Key<Defaults.MainWindowBackgroundStyle> = .init(
        "mainWindowBackgroundStyle",
        default: .vibrant
    )
    static let miniPlayerBackgroundStyle: Key<Defaults.MiniPlayerBackgroundStyle> = .init(
        "miniPlayerBackgroundStyle",
        default: .dynamicallyTinted
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
}
