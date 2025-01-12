//
//  Track.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/20.
//

import AppKit
import CSFBAudioEngine
import Luminare
import SwiftUI

struct Track: Identifiable, RawRepresentable {
    let id = UUID()
    let url: URL
    @State var metadata: Metadata

    var rawValue: URL { url }

    init?(url: URL) {
        self.url = url

        guard let metadata = Metadata(url: url) else { return nil }
        self.metadata = metadata
    }

    init?(rawValue: URL) {
        self.init(url: rawValue)
    }

    init(url: URL, metadata: Metadata) {
        self.url = url
        self.metadata = metadata
    }
}

extension Track: Equatable {
    static func == (lhs: Track, rhs: Track) -> Bool {
        lhs.id == rhs.id
    }
}

extension Track: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Track: LuminareSelectionData {
    var isSelectable: Bool {
        metadata.state.isLoaded
    }
}
