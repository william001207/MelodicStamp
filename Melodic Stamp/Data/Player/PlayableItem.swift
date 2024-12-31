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

    init?(url: URL) {
        self.url = url

        guard let metadata = Metadata(url: url) else { return nil }
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

extension PlayableItem: LuminareSelectionData {
    var isSelectable: Bool {
        metadata.state.isLoaded
    }
}
