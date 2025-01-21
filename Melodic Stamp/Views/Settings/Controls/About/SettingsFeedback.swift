//
//  SettingsFeedback.swift
//  Melodic Stamp
//
//  Created by Xinshao_Air on 2025/1/21.
//

import SwiftUI

struct SettingsFeedback: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        HStack(spacing: 10) {
            Button("Feedback") {
                if let url = URL(string: "https://github.com/Cement-Labs/Melodic-Stamp/issues") {
                    openURL(url)
                }
            }
            .buttonStyle(.link)

            Button("Join the group chat") {
                if let url = URL(string: "https://qm.qq.com/q/txBDJxnw4i") {
                    openURL(url)
                }
            }
            .buttonStyle(.link)
        }
    }
}

#Preview {
    Form {
        SettingsFeedback()
    }
    .formStyle(.grouped)
}
