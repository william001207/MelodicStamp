//
//  MetadataEditorModel.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/24.
//

import SwiftUI

enum MetadataValueState<V: Equatable & Hashable> {
    case undefined
    case fine(entry: MetadataBatchEditingEntry<V>)
    case varied(entries: MetadataBatchEditingEntries<V>)
}

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

    var items: Set<PlaylistItem> = .init()

    var metadatas: Set<Metadata> {
        Set(items.map(\.metadata))
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

    subscript<V: Equatable & Hashable>(extracting keyPath: WritableKeyPath<Metadata, MetadataEntry<V>>) -> MetadataValueState<V> {
        guard isVisible else { return .undefined }

        let values = metadatas.map(\.[extracting: keyPath]).map(\.current)
        let areIdentical = values.allSatisfy { $0 == values[0] }

        return if areIdentical {
            .fine(entry: .init(keyPath: keyPath, metadatas: metadatas))
        } else {
            .varied(entries: .init(keyPath: keyPath, metadatas: metadatas))
        }
    }
}

extension MetadataEditorModel: Modifiable {
    var isModified: Bool {
        !metadatas.filter(\.isModified).isEmpty
    }
}
