//
//  ToolbarLabel.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/25.
//

import SFSafeSymbols
import SwiftUI

struct ToolbarLabel<Content>: View where Content: View {
    @Environment(\.isEnabled) private var isEnabled

    @ViewBuilder var content: () -> Content

    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            content()
        }
        .padding(.horizontal, 2)
        .opacity(isEnabled ? 1 : 0.35)
        .animation(.default, value: isEnabled)
    }
}

struct ToolbarImageLabel: View {
    @Environment(\.isEnabled) private var isEnabled

    var systemSymbol: SFSymbol

    var body: some View {
        ToolbarLabel {
            // Text interpolation is used to obtain the button border
            Text("\(Image(systemSymbol: systemSymbol))")
                .baselineOffset(-1)
                .frame(width: 14)
        }
    }
}
