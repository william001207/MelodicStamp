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
                SettingsExcerptView(.general, descriptionKey: "General settings excerpt.")
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
