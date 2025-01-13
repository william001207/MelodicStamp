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
//        Slider(
//            value: typeSizeBinding,
//            in: typeSizesBinding.wrappedValue,
//            step: 1
//        ) {
//            Text("Type size")
//        } minimumValueLabel: {
//            DynamicTypeSizeView(typeSize: typeSizes.lowerBound)
//        } maximumValueLabel: {
//            DynamicTypeSizeView(typeSize: typeSizes.upperBound)
//        }
        Text("")
    }
    
    private var typeSizeBinding: Binding<Int> {
        Binding {
            typeSize.rawValue
        } set: { newValue in
            guard let typeSize = Defaults.DynamicTypeSize(rawValue: newValue) else { return }
            
            self.typeSize = typeSize.clamped
        }
    }
    
    private var typeSizesBinding: Binding<ClosedRange<Int>> {
        Binding {
            typeSizes.lowerBound.rawValue...typeSizes.upperBound.rawValue
        } set: { newValue in
            guard
                let lowerBound = Defaults.DynamicTypeSize(rawValue: newValue.lowerBound),
                let upperBound = Defaults.DynamicTypeSize(rawValue: newValue.upperBound)
            else { return }
            
            self.typeSizes = lowerBound...upperBound
        }
    }
}

#Preview {
    SettingsLyricTypeSizeControl()
        .padding()
}
