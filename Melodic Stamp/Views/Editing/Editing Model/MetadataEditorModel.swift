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

@Observable class MetadataEditorModel: Identifiable {
    let id: UUID = .init()
    
    var items: Set<PlaylistItem> = .init()
    
    var editableMetadatas: Set<EditableMetadata> {
        Set(items.map(\.editableMetadata))
    }
    
    var hasEditableMetadata: Bool {
        !editableMetadatas.isEmpty
    }
    
    func revertAll() {
        editableMetadatas.forEach { $0.revert() }
    }
    
    func writeAll() {
        editableMetadatas.forEach { editableMetadata in
            Task {
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
