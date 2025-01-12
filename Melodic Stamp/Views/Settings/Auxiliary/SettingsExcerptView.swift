//
//  SettingsExcerptView.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/12.
//

import SwiftUI

struct SettingsExcerptView<Content>: View where Content: View {
    var tab: SettingsTab
    @ViewBuilder var content: () -> Content

    init(_ tab: SettingsTab, content: @escaping () -> Content) {
        self.tab = tab
        self.content = content
    }

    init(_ tab: SettingsTab, descriptionKey: LocalizedStringKey) where Content == Text {
        self.init(tab) {
            Text(descriptionKey)
        }
    }

    init(_ tab: SettingsTab) where Content == EmptyView {
        self.init(tab) {
            EmptyView()
        }
    }

    var body: some View {
        VStack {
            SettingsBannerIcon(tab)

            Text(tab.name)
                .font(.title)

            if Content.self != EmptyView.self {
                content()
                    .foregroundStyle(.secondary)
            }
        }
        .padding(7)
    }
}

#Preview {
    SettingsExcerptView(.general) {
        Text("General settings excerpt.")
    }
}
