//
//  OutputDeviceList.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/5.
//

import CAAudioHardware
import Defaults
import SwiftUI

struct OutputDeviceList: View {
    enum Style {
        case plain
        case menu
    }

    var devices: [AudioDevice]
    var defaultSystemDevice: AudioDevice?
    var style: Style = .menu

    var body: some View {
        if let defaultSystemDevice {
            Group {
                switch style {
                case .plain:
                    OutputDeviceView()
                case .menu:
                    Button {
                        // A hack to show a subtitle in a menu row
                    } label: {
                        OutputDeviceView()
                        OutputDeviceView(device: defaultSystemDevice)
                    }
                }
            }
            .tag(nil as AudioDevice?)
        }

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
        .init(grouping: devices) { try? $0.transportType }
    }

    @ViewBuilder private func deviceList(in devices: [AudioDevice]) -> some View {
        ForEach(devices, id: \.objectID) { device in
            OutputDeviceView(device: device)
                .tag(device)
        }
    }
}
