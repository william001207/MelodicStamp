//
//  SettingsLyricAttachmentsControl.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/12.
//

import Defaults
import SwiftUI

struct SettingsLyricAttachmentsControl: View {
    @Default(.lyricsAttachments) private var lyricAttachments

    var body: some View {
        Toggle("Translation", isOn: binding(of: .translation))
        Toggle("Roman", isOn: binding(of: .roman))
    }

    private func binding(of option: LyricsAttachments.Element) -> Binding<Bool> {
        Binding {
            lyricAttachments.contains(option)
        } set: { newValue in
            if newValue {
                lyricAttachments.insert(option)
            } else {
                lyricAttachments.remove(option)
            }
        }
    }
}
