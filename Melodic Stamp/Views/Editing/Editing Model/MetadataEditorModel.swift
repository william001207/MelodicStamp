//
//  MetadataEditorModel.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/24.
//

import SwiftUI

enum MetadataValueState<V: Equatable> {
    case undefined
    case fine(EditableMetadata.Values<V>)
    case varied(EditableMetadata.ValueSetter<V>)
}

enum MetadataEditingState {
    case fine
    case partialSaving
    case saving
    
    var isAvailable: Bool {
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
        return if states.allSatisfy({ $0 == .fine }) {
            .fine
        } else if states.allSatisfy({ $0 == .saving }) {
            .saving
        } else {
            .partialSaving
        }
    }
    
    func revertAll() {
        editableMetadatas.forEach { $0.revert() }
    }
    
    func updateAll() {
        editableMetadatas.forEach { editableMetadata in
            Task.detached {
                try await editableMetadata.update()
            }
        }
    }
    
    func writeAll() {
        editableMetadatas.forEach { editableMetadata in
            Task.detached {
                try await editableMetadata.write()
            }
        }
    }
    
    subscript<V: Equatable>(extracting keyPath: WritableKeyPath<Metadata, V>) -> MetadataValueState<V> {
        guard hasEditableMetadata else { return .undefined }
        
        let setter = EditableMetadata.ValueSetter(keyPath: keyPath, editableMetadatas: editableMetadatas)
        let values = editableMetadatas
            .map { $0[extracting: keyPath] }
        let areIdentical = values.allSatisfy { $0.current == values[0].current }
        
        return areIdentical ? .fine(values[0]) : .varied(setter)
    }
}
