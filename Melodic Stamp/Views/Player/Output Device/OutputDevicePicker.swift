//
//  OutputDevicePicker.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/6.
//

import CAAudioHardware
import SwiftUI

struct OutputDevicePicker: View {
    var devices: [AudioDevice]
    @Binding var selection: AudioDevice?

    var body: some View {
        if let binding = ~$selection {
            let name = try? binding.wrappedValue.name

            Picker(name ?? .init(localized: "Output Device"), selection: binding) {
                OutputDeviceList(devices: devices)
            }
        }
    }
}
