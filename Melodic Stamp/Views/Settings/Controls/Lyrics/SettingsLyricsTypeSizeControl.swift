//
//  SettingsLyricsTypeSizeControl.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/13.
//

import Defaults
import SwiftUI

struct SettingsLyricsTypeSizeControl: View {
    @Default(.lyricsTypeSize) private var typeSize
    @Default(.lyricsTypeSizes) private var typeSizes

    var rangeSliderMinWidth: CGFloat = 300

    var body: some View {
        if typeSizes.lowerBound < typeSizes.upperBound {
            Slider(
                value: typeSizeBinding,
                in: typeSizesBinding.wrappedValue,
                step: 1
            ) {
                Text("Type size")
                DynamicTypeSizeView(typeSize: typeSize)
            } minimumValueLabel: {
                DynamicTypeSizeView(typeSize: typeSizes.lowerBound)
            } maximumValueLabel: {
                DynamicTypeSizeView(typeSize: typeSizes.upperBound)
            }
        } else {
            LabeledContent {
                DynamicTypeSizeView(typeSize: typeSize)
            } label: {
                Text("Type size")
            }
        }

        LabeledContent {
            HStack(alignment: .center) {
                Button {
                    var lowerBound = typeSizes.lowerBound
                    lowerBound -~ .minimum
                    typeSizes = lowerBound...typeSizes.upperBound
                } label: {
                    DynamicTypeSizeView(typeSize: .minimum)
                        .font(.caption)
                }
                .buttonStyle(.borderless)

                RangeSlider(
                    range: typeSizesBinding,
                    in: 0...Double(DynamicTypeSize.maximum.rawValue)
                )
                .frame(minWidth: rangeSliderMinWidth)

                Button {
                    var upperBound = typeSizes.upperBound
                    upperBound +~ .maximum
                    typeSizes = typeSizes.lowerBound...upperBound
                } label: {
                    DynamicTypeSizeView(typeSize: .maximum)
                        .font(.caption)
                }
                .buttonStyle(.borderless)
            }
        } label: {
            Text("Available type sizes")
            HStack {
                DynamicTypeSizeView(typeSize: typeSizes.lowerBound)
                Image(systemSymbol: .ellipsis)
                DynamicTypeSizeView(typeSize: typeSizes.upperBound)
            }
        }
        .onChange(of: typeSizes) { _, _ in
            typeSize = typeSize.dynamicallyClamped
        }
    }

    private var typeSizeBinding: Binding<Double> {
        Binding {
            Double(typeSize.rawValue)
        } set: { newValue in
            guard let typeSize = Defaults.DynamicTypeSize(rawValue: Int(newValue)) else { return }

            self.typeSize = typeSize.dynamicallyClamped
        }
    }

    private var typeSizesBinding: Binding<ClosedRange<Double>> {
        Binding {
            Double(typeSizes.lowerBound.rawValue)...Double(typeSizes.upperBound.rawValue)
        } set: { newValue in
            guard
                let lowerBound = Defaults.DynamicTypeSize(rawValue: Int(newValue.lowerBound)),
                let upperBound = Defaults.DynamicTypeSize(rawValue: Int(newValue.upperBound))
            else { return }

            typeSizes = lowerBound...upperBound
        }
    }
}

#Preview {
    Form {
        Section {
            SettingsLyricsTypeSizeControl()
        }
    }
    .formStyle(.grouped)
}
