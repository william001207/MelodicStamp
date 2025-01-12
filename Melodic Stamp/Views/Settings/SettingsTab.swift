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
    case general
    case visualization
    case lyrics
    case performance

    var id: Self { self }

    var systemSymbol: SFSymbol {
        switch self {
        case .general: .gear
        case .visualization: .waveform
        case .lyrics: .musicNoteList
        case .performance: .gaugeWithDotsNeedle67percent
        }
    }

    var color: Color {
        switch self {
        case .general: .gray
        case .visualization: .pink
        case .lyrics: .orange
        case .performance: .green
        }
    }

    var name: String {
        switch self {
        case .general: .init(localized: "General")
        case .visualization: .init(localized: "Visualization")
        case .lyrics: .init(localized: "Lyrics")
        case .performance: .init(localized: "Performance")
        }
    }
}
