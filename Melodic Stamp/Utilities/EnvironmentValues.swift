//
//  EnvironmentValues.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/23.
//

import SwiftUI

extension EnvironmentValues {
    @Entry var lyricsAttachments: LyricsAttachments = .all
    @Entry var lyricsTypeSizes: ClosedRange<DynamicTypeSize> = .small...(.xxLarge)
}
