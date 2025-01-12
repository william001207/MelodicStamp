//
//  SettingsLyricsLyricAttachmentsControl.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/12.
//

import Defaults
import SwiftUI

struct SettingsLyricsLyricAttachmentsControl: View {
    @Default(.lyricAttachments) private var lyricAttachments
    
    var body: some View {
        Toggle("Translation", isOn: binding(of: .translation))
        Toggle("Roman", isOn: binding(of: .roman))
    }
    
    private func binding(of option: LyricAttachments.Element) -> Binding<Bool> {
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
