//
//  SettingsLyricsAttachmentsControl.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/12.
//

import Defaults
import SwiftUI

struct SettingsLyricsAttachmentsControl: View {
    @Default(.lyricsAttachments) private var attachments

    var body: some View {
        Toggle("Translation", isOn: binding(of: .translation))
        Toggle("Roman", isOn: binding(of: .roman))
    }

    private func binding(of option: LyricsAttachments.Element) -> Binding<Bool> {
        Binding {
            attachments.contains(option)
        } set: { newValue in
            if newValue {
                attachments.insert(option)
            } else {
                attachments.remove(option)
            }
        }
    }
}
