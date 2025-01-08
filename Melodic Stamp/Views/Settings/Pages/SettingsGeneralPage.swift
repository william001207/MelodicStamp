//
//  SettingsGeneralPage.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/5.
//

import Defaults
import SwiftUI

struct SettingsGeneralPage: View {
    var body: some View {
        LazyVStack {
            Section {
                VStack {
                    SettingsView.bannerIcon(.gear, color: .gray)

                    Text("General")
                        .font(.title)

                    Text("This is a sample description.")
                        .foregroundStyle(.secondary)
                }
                .padding(7)
            }
        }
    }
}

#Preview {
    Form {
        SettingsGeneralPage()
    }
    .formStyle(.grouped)
}
