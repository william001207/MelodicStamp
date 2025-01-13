//
//  OutputDeviceList.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/5.
//

import CAAudioHardware
import SwiftUI

struct OutputDeviceList: View {
    var devices: [AudioDevice]

    var body: some View {
        ForEach(
            groupedDevices
                .sorted { $0.key?.rawValue ?? 0 < $1.key?.rawValue ?? 0 },
            id: \.key
        ) { type, devices in
            if let type {
                Section {
                    deviceList(in: devices)
                } header: {
                    AudioDeviceTransportTypeView(type: type)
                }
            } else {
                deviceList(in: devices)
            }
        }
    }

    private var groupedDevices: [AudioDevice.TransportType?: [AudioDevice]] {
        do {
            return try .init(grouping: devices) { try $0.transportType }
        } catch {
            return [nil: devices]
        }
    }

    @ViewBuilder private func deviceList(in devices: [AudioDevice]) -> some View {
        ForEach(devices, id: \.objectID) { device in
            OutputDeviceView(device: device)
                .tag(device)
        }
    }
}
