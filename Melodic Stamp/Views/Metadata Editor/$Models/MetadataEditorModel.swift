//
//  MetadataEditorModel.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/24.
//

import SwiftUI

enum MetadataEditingState: Equatable {
    case fine
    case saving
    case partiallySaving

    var isEditable: Bool {
        switch self {
        case .fine:
            true
        default:
            false
        }
    }
}

@Observable class MetadataEditorModel: Identifiable {
    let id: UUID = .init()

    var tracks: Set<Track> = []

    var metadatas: Set<Metadata> {
        Set(tracks.map(\.metadata).filter(\.state.isProcessed))
    }

    var isVisible: Bool {
        !metadatas.isEmpty
    }

    var state: MetadataEditingState {
        let states = metadatas.map(\.state)
        return if states.allSatisfy(\.isEditable) {
            .fine
        } else if states.allSatisfy({ !$0.isEditable }) {
            .saving
        } else {
            .partiallySaving
        }
    }

    func restoreAll() {
        metadatas.forEach { $0.restore() }
    }

    func updateAll() {
        for metadata in metadatas {
            Task.detached {
                try await metadata.update()
            }
        }
    }

    func writeAll() {
        for metadata in metadatas {
            Task.detached {
                try await metadata.write()
            }
        }
    }

    subscript<V: Equatable & Hashable>(extracting keyPath: WritableKeyPath<Metadata, MetadataEntry<V>>) -> MetadataBatchEditingEntries<V> {
        .init(keyPath: keyPath, metadatas: metadatas)
    }
}

extension MetadataEditorModel: Modifiable {
    var isModified: Bool {
        metadatas.contains(where: \.isModified)
    }
}
