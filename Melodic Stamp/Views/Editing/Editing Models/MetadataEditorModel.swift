//
//  MetadataEditorModel.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/24.
//

import SwiftUI

enum MetadataValueState<V: Equatable & Hashable> {
    case undefined
    case fine(value: BatchEditableMetadataValue<V>)
    case varied(values: BatchEditableMetadataValues<V>)
}

enum MetadataEditingState: Equatable {
    case fine
    case partiallySaving
    case saving

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

    var editableMetadatas: Set<EditableMetadata> {
        Set(items.map(\.editableMetadata))
    }

    var hasEditableMetadata: Bool {
        !editableMetadatas.isEmpty
    }

    var state: MetadataEditingState {
        let states = editableMetadatas.map(\.state)
        return if states.allSatisfy(\.isEditable) {
            .fine
        } else if states.allSatisfy({ !$0.isEditable }) {
            .saving
        } else {
            .partiallySaving
        }
    }

    func revertAll() {
        editableMetadatas.forEach { $0.restore() }
    }

    func updateAll() {
        for editableMetadata in editableMetadatas {
            Task.detached {
                try await editableMetadata.update()
            }
        }
    }

    func writeAll() {
        for editableMetadata in editableMetadatas {
            Task.detached {
                try await editableMetadata.write()
            }
        }
    }

    subscript<V: Equatable & Hashable>(extracting keyPath: WritableKeyPath<Metadata, V>) -> MetadataValueState<V> {
        guard hasEditableMetadata else { return .undefined }

        let values = editableMetadatas.map(\.current).map { $0[keyPath: keyPath] }
        let areIdentical = values.allSatisfy { $0 == values[0] }

        return if areIdentical {
            .fine(value: .init(keyPath: keyPath, editableMetadatas: editableMetadatas))
        } else {
            .varied(values: .init(keyPath: keyPath, editableMetadatas: editableMetadatas))
        }
    }
}
