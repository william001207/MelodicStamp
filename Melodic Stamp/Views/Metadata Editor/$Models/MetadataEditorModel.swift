//
//  MetadataEditorModel.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/24.
//

import SwiftUI

@MainActor @Observable class MetadataEditorModel: MetadataEditorProtocol {
    let id: UUID = .init()

    var tracks: Set<Track> = []

    var metadatas: Set<Metadata> {
        Set(tracks.map(\.metadata).filter(\.state.isInitialized))
    }

    subscript<V: Equatable & Hashable>(extracting keyPath: WritableKeyPath<Metadata, MetadataEntry<V>>) -> MetadataBatchEditingEntries<V> {
        .init(keyPath: keyPath, metadatas: metadatas)
    }
}
