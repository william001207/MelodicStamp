//
//  OutputDeviceView.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/5.
//

import CAAudioHardware
import SwiftUI

struct OutputDeviceView: View {
    var device: AudioDevice

    var body: some View {
        HStack {
            if let name {
                Text(name)
            } else {
                Text("Unknown Device")
            }

            if let icon {
                icon
            }
        }
    }

    private var name: String? {
        do {
            return try device.name
        } catch {
            return nil
        }
    }

    private var icon: AsyncImage<Image>? {
        do {
            return try AsyncImage(url: device.icon)
        } catch {
            return nil
        }
    }
}

#Preview {
    var device: AudioDevice? {
        do {
            return try .defaultInputDevice
        } catch {
            return nil
        }
    }

    if let device {
        OutputDeviceView(device: device)
            .padding()
    }
}
