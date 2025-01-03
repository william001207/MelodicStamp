//
//  PlayableItem.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/20.
//

import AppKit
import CSFBAudioEngine
import Luminare
import SwiftUI

struct PlayableItem: Identifiable {
    let id = UUID()
    let url: URL
    @State var metadata: Metadata

    init?(url: URL) async {
        self.url = url

        guard let metadata = await Metadata(url: url) else { return nil }
        self.metadata = metadata
    }

    init(url: URL, metadata: Metadata) {
        self.url = url
        self.metadata = metadata
    }
}

extension PlayableItem: Equatable {
    static func == (lhs: PlayableItem, rhs: PlayableItem) -> Bool {
        lhs.id == rhs.id
    }
}

extension PlayableItem: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension PlayableItem: @preconcurrency LuminareSelectionData {
    @MainActor var isSelectable: Bool {
        metadata.state.isLoaded
    }
}
