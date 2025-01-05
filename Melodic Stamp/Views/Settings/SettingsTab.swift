//
//  SettingsTab.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/5.
//

import Foundation

enum SettingsTab: Hashable, Equatable, Identifiable, CaseIterable {
    case general
    case visualization

    var id: Self { self }
}
