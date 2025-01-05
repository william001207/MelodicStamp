//
//  AudioDeviceTransportTypeView.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/5.
//

import CAAudioHardware
import SwiftUI

struct AudioDeviceTransportTypeView: View {
    var type: AudioDevice.TransportType

    var body: some View {
        switch type {
        case .aggregate: Text("Aggregate")
        case .airPlay: Text("AirPlay")
        case .avb: Text("AVB")
        case .bluetooth: Text("Bluetooth")
        case .bluetoothLE: Text("Bluetooth LE")
        case .builtIn: Text("Built-in")
        case .continuityCaptureWired: Text("Continuity Capture (Wired)")
        case .continuityCaptureWireless: Text("Continuity Capture (Wireless)")
        case .displayPort: Text("DisplayPort")
        case .fireWire: Text("FireWire")
        case .hdmi: Text("HDMI")
        case .pci: Text("PCI")
        case .thunderbolt: Text("Thunderbolt")
        case .usb: Text("USB")
        case .virtual: Text("Virtual")
        default: Text("Unknown")
        }
    }
}

#Preview {
    AudioDeviceTransportTypeView(type: .builtIn)
}
