//
//  DisplayLyricsScrollabilityButton.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/1.
//

import SFSafeSymbols
import SwiftUI

struct DisplayLyricsScrollabilityButton: View, Animatable {
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    @Namespace private var namespace

    @Binding var scrollability: BouncyScrollViewScrollability
    var progress: CGFloat
    var lineWidth: CGFloat = 4
    var hasProgressRing: Bool = true

    var body: some View {
        AliveButton(isOn: binding) {
            ZStack {
                Circle()
                    .foregroundStyle(.background)
                    .opacity(0.1)
                    .frame(width: 48)
                    .overlay {
                        if hasProgressRing {
                            ProgressView(value: max(0, min(1, progress)))
                                .progressViewStyle(.alive(lineWidth: lineWidth))
                                .padding(lineWidth / 2)
                        }
                    }

                Group {
                    if scrollability.isControlledByUser {
                        Image(systemSymbol: .lockOpenFill)
                    } else {
                        Image(systemSymbol: .lockFill)
                    }
                }
                .font(.title2)
            }
            .padding(12)
        }
        .animation(.default, value: hasProgressRing)
        .animation(.default, value: scrollability)
    }

    private var binding: Binding<Bool> {
        Binding {
            scrollability.isControlledByUser
        } set: { newValue in
            if newValue {
                scrollability = .definedByUser
            } else {
                scrollability = .scrollsToHighlighted
            }
        }
    }
}

#Preview {
    @Previewable @State var scrollability: BouncyScrollViewScrollability = .scrollsToHighlighted
    @Previewable @State var progress: CGFloat = .zero

    VStack {
        DisplayLyricsScrollabilityButton(scrollability: $scrollability, progress: progress)

        Slider(value: $progress, in: 0...1)
    }
    .padding()
}
