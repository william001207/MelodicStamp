//
//  SettingsTab.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/5.
//

import Foundation
import SFSafeSymbols
import SwiftUICore

enum SettingsTab: Hashable, Equatable, Identifiable, CaseIterable {
    case appearance
    case visualization
    case lyrics

    case launchBehaviors
    case performance

    var id: Self { self }

    var systemSymbol: SFSymbol {
        switch self {
        case .appearance: .paintbrushFill
        case .visualization: .waveform
        case .lyrics: .musicNoteList
        case .launchBehaviors: .airplaneDeparture
        case .performance: .gaugeWithDotsNeedle67percent
        }
    }

    var color: Color {
        switch self {
        case .appearance: .accent
        case .visualization: .pink
        case .lyrics: .orange
        case .launchBehaviors: .blue
        case .performance: .green
        }
    }

    var name: String {
        switch self {
        case .appearance: .init(localized: "Appearance")
        case .visualization: .init(localized: "Visualization")
        case .lyrics: .init(localized: "Lyrics")
        case .launchBehaviors: .init(localized: "Launch Behaviors")
        case .performance: .init(localized: "Performance")
        }
    }
}
