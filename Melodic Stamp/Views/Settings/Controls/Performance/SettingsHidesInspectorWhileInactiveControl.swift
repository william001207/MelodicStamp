//
//  SettingsHidesInspectorWhileInactiveControl.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/17.
//

import Defaults
import SwiftUI

struct SettingsHidesInspectorWhileInactiveControl: View {
    @Default(.hidesInspectorWhileInactive) var isEnabled

    var body: some View {
        Toggle("Stops rendering inspector", isOn: $isEnabled)
    }
}
