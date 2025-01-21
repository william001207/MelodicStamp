//
//  SettingsContributorsControl.swift
//  Melodic Stamp
//
//  Created by Xinshao_Air on 2025/1/21.
//

import SFSafeSymbols
import SwiftUI

struct SettingsContributorsControl: View {
    var body: some View {
        List {
            contributor(
                avatarSource: .remote(.github.appending(component: "KrLite.png")),
                "KrLite",
                "Organization, design, and development."
            )

            contributor(
                avatarSource: .remote(.github.appending(component: "Xinshao-air.png")),
                "芯梢",
                "Design, test, and development support."
            )
        }
    }

    @ViewBuilder private func contributor(
        avatarSource: ContributorAvatarSource,
        _ name: String,
        _ descriptionKey: LocalizedStringKey?
    ) -> some View {
        HStack {
            ContributorAvatarView(source: avatarSource)

            VStack(alignment: .leading) {
                Text(verbatim: name)
                    .font(.headline)

                if let descriptionKey {
                    Text(descriptionKey)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

#Preview {
    Form {
        SettingsContributorsControl()
    }
    .formStyle(.grouped)
}
