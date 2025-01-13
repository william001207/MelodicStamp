//
//  EnvironmentValues.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/23.
//

import SwiftUI

extension EnvironmentValues {
    @Entry var lyricAttachments: LyricAttachments = .all
    @Entry var lyricTypeSizes: ClosedRange<DynamicTypeSize> = .small...(.xxLarge)
}
