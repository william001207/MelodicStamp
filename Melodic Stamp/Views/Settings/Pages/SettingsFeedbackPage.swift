//
//  SettingsFeedbackPage.swift
//  Melodic Stamp
//
//  Created by Xinshao_Air on 2025/1/21.
//

import SwiftUI

struct SettingsFeedbackPage: View {
    var body: some View {
        SettingsExcerptView(
            .feedback,
            descriptionKey: "Feedback on issues and provide suggestions."
        )

        Section {
            SettingsAboutDeveloper()
        } header: {
            Text("Developer")
            Text("""
            We completed this app during our break time. Currently, it is not perfect and we look forward to the addition of more contributors.
            """)
        }

        Section {
            SettingsFeedback()
        } header: {
            Text("Feedback")
            Text("""
            Share your feedback on our GitHub page! Whether you find a bug or want to suggest a new feature, feel free to speak up.
            """)
        }
    }
}

#Preview {
    Form {
        SettingsFeedbackPage()
    }
    .formStyle(.grouped)
}
