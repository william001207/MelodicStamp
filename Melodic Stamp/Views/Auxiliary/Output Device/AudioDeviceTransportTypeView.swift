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
        Text(Self.name(of: type))
    }

    static func name(of type: AudioDevice.TransportType) -> String {
        switch type {
        case .aggregate:
            String(localized: .init("Audio Device: (Transport Type) Aggregate", defaultValue: "Aggregate"))
        case .airPlay:
            String(localized: .init("Audio Device: (Transport Type) AirPlay", defaultValue: "AirPlay"))
        case .avb:
            String(localized: .init("Audio Device: (Transport Type) AVB", defaultValue: "AVB"))
        case .bluetooth:
            String(localized: .init("Audio Device: (Transport Type) Bluetooth", defaultValue: "Bluetooth"))
        case .bluetoothLE:
            String(localized: .init("Audio Device: (Transport Type) Bluetooth (Low Energy)", defaultValue: "Bluetooth (Low Energy)"))
        case .builtIn:
            String(localized: .init("Audio Device: (Transport Type) Built-in", defaultValue: "Built-in"))
        case .continuityCaptureWired:
            String(localized: .init("Audio Device: (Transport Type) Continuity Capture (Wired)", defaultValue: "Continuity Capture (Wired)"))
        case .continuityCaptureWireless:
            String(localized: .init("Audio Device: (Transport Type) Continuity Capture (Wireless)", defaultValue: "Continuity Capture (Wireless)"))
        case .displayPort:
            String(localized: .init("Audio Device: (Transport Type) DisplayPort", defaultValue: "DisplayPort"))
        case .fireWire:
            String(localized: .init("Audio Device: (Transport Type) FireWire", defaultValue: "FireWire"))
        case .hdmi:
            String(localized: .init("Audio Device: (Transport Type) HDMI", defaultValue: "HDMI"))
        case .pci:
            String(localized: .init("Audio Device: (Transport Type) PCI", defaultValue: "PCI"))
        case .thunderbolt:
            String(localized: .init("Audio Device: (Transport Type) Thunderbolt", defaultValue: "Thunderbolt"))
        case .usb:
            String(localized: .init("Audio Device: (Transport Type) USB", defaultValue: "USB"))
        case .virtual:
            String(localized: .init("Audio Device: (Transport Type) Virtual", defaultValue: "Virtual"))
        default:
            String(localized: .init("Audio Device: (Transport Type) Unknown", defaultValue: "Unknown"))
        }
    }
}

#Preview {
    AudioDeviceTransportTypeView(type: .builtIn)
}
