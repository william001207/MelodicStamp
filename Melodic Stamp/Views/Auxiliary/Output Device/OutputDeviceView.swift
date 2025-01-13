//
//  OutputDeviceView.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/5.
//

import CAAudioHardware
import SwiftUI

struct OutputDeviceView: View {
    var device: AudioDevice?

    var body: some View {
        HStack {
            Text(Self.name(of: device))
        }
    }

    static func name(of device: AudioDevice?) -> String {
        if let device {
            do {
                return try device.name
            } catch {
                return .init(localized: "Unknown Device")
            }
        } else {
            return .init(localized: "System Default")
        }
    }
}

#Preview {
    var device: AudioDevice? {
        try? .defaultInputDevice
    }

    OutputDeviceView(device: device)
        .padding()
}
