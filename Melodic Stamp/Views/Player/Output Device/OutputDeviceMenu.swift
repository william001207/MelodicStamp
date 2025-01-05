//
//  OutputDeviceMenu.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/5.
//

import CAAudioHardware
import SwiftUI

struct OutputDeviceMenu<Label>: View where Label: View {
    @Environment(PlayerModel.self) private var player

    @ViewBuilder var label: () -> Label

    var body: some View {
        if let outputDevice = player.selectedOutputDevice {
            let binding: Binding<AudioDevice> = Binding {
                outputDevice
            } set: { newValue in
                player.selectOutputDevice(newValue)
            }

            Picker(selection: binding) {
                ForEach(outputDevices.map { ($0, $1) }, id: \.0) { type, devices in
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
            } label: {
                label()
            }
        }
    }

    private var outputDevices: [AudioDevice.TransportType?: [AudioDevice]] {
        do {
            return try .init(grouping: player.outputDevices) { try $0.transportType }
        } catch {
            return [nil: player.outputDevices]
        }
    }

    @ViewBuilder private func deviceList(in devices: [AudioDevice]) -> some View {
        ForEach(devices, id: \.objectID) { device in
            OutputDeviceView(device: device)
                .tag(device)
        }
    }
}

#Preview(traits: .modifier(SampleEnvironmentsPreviewModifier())) {
    OutputDeviceMenu {
        Text("Output Device")
    }
}
