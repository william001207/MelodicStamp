//
//  SettingsReduceMotionControl.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/2/1.
//

import Defaults
import SwiftUI

struct SettingsReduceMotionControl: View {
    @Default(.reduceMotion) private var reduceMotion

    var body: some View {
        Toggle("Reduce motion", isOn: $reduceMotion)
    }
}
