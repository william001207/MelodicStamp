//
//  MetadataEditorModel.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/24.
//

import SwiftUI

@MainActor @Observable class MetadataEditorModel: MetadataEditorProtocol {
    private weak var player: PlayerModel?

    init(player: PlayerModel) {
        self.player = player
    }

    var metadataSet: Set<Metadata> {
        guard let player else {
            return []
        }
        return Set(player.selectedTracks.map(\.metadata).filter(\.state.isInitialized))
    }

    subscript<V: Equatable & Hashable>(extracting keyPath: WritableKeyPath<Metadata, MetadataEntry<V>>) -> MetadataBatchEditingEntries<V> {
        .init(keyPath: keyPath, metadatas: metadataSet)
    }
}
