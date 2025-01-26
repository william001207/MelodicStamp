//
//  MetadataEditorModel.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/24.
//

import SwiftUI

struct MetadataEditingState: OptionSet {
    let rawValue: Int

    static let fine = MetadataEditingState(rawValue: 1 << 0)
    static let saving = MetadataEditingState(rawValue: 1 << 1)

    var isFine: Bool {
        switch self {
        case .fine:
            true
        default:
            false
        }
    }

    var isSaving: Bool {
        switch self {
        case .saving:
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
        Set(tracks.map(\.metadata).filter(\.state.isInitialized))
    }

    var hasMetadatas: Bool {
        !metadatas.isEmpty
    }

    var state: MetadataEditingState {
        guard hasMetadatas else { return [] }

        var result: MetadataEditingState = []
        let states = metadatas.map(\.state)

        for state in states {
            switch state {
            case .fine:
                result.formUnion(.fine)
            case .saving:
                result.formUnion(.saving)
            default:
                break
            }
        }

        return result
    }

    @MainActor func restoreAll() {
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
