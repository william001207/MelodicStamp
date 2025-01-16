//
//  SettingsLyricsMaxWidthControl.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/16.
//

import Defaults
import SwiftUI

struct SettingsLyricsMaxWidthControl: View {
    @Default(.lyricsMaxWidth) private var maxWidth

    var body: some View {
        Slider(
            value: $maxWidth.value,
            in: Defaults.LyricsMaxWidth.range.map(Double.init)
        ) {
            Text("Max lyrics width")
            TextField(
                value: $maxWidth.value,
                format: .number.precision(.integerAndFractionLength(integerLimits: 0..., fractionLimits: ...2))
            ) {
                EmptyView()
            }
            .labelsHidden()
            .font(.caption)
            .monospaced()
            .foregroundStyle(.secondary)
        } minimumValueLabel: {
            Text(verbatim: .init(format: "%.2f", Defaults.LyricsMaxWidth.range.lowerBound.value))
        } maximumValueLabel: {
            Text(verbatim: .init(format: "%.2f", Defaults.LyricsMaxWidth.range.upperBound.value))
        }
    }
}
