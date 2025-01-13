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
    var defaultSystemDevice: AudioDevice?
    @Binding var selection: AudioDevice?

    var body: some View {
        Picker(selection: $selection) {
            OutputDeviceList(devices: devices, defaultSystemDevice: defaultSystemDevice)
        } label: {
            if let selection {
                OutputDeviceView(device: selection)

                if let type = try? selection.transportType {
                    AudioDeviceTransportTypeView(type: type)
                }
            } else {
                OutputDeviceView()

                OutputDeviceView(device: defaultSystemDevice)
            }
        }
    }
}
