//
//  SettingsLyricTypeSizeControl.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/13.
//

import Defaults
import SwiftUI

struct SettingsLyricTypeSizeControl: View {
    @Default(.lyricsTypeSize) private var typeSize
    @Default(.lyricsTypeSizes) private var typeSizes
    
    var body: some View {
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
    }
    
    private var typeSizeBinding: Binding<Double> {
        Binding {
            Double(typeSize.rawValue)
        } set: { newValue in
            guard let typeSize = Defaults.DynamicTypeSize(rawValue: Int(newValue)) else { return }
            
            self.typeSize = typeSize.clamped
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
            
            self.typeSizes = lowerBound...upperBound
        }
    }
}

#Preview {
    Form {
        Section {
            SettingsLyricTypeSizeControl()
        }
    }
    .formStyle(.grouped)
}
