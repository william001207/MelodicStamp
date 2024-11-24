//
//  MetadataEditingModel.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/24.
//

import SwiftUI
import CSFBAudioEngine

struct EditableMetadata: Identifiable, Hashable {
    struct Values<V> {
        let keyPath: WritableKeyPath<Metadata, V>
        let metadata: EditableMetadata
        
        var current: V {
            get { metadata.metadata[keyPath: keyPath] }
            nonmutating set { metadata.metadata[keyPath: keyPath] = newValue }
        }
        
        private(set) var initlal: V {
            get { metadata.initialMetadata[keyPath: keyPath] }
            nonmutating set { metadata.initialMetadata[keyPath: keyPath] = newValue }
        }
        
        func revert() {
            current = initlal
        }
        
        func apply() {
            self.initlal = current
        }
    }
    
    struct Setter<V> {
        let keyPath: WritableKeyPath<Metadata, V>
        let metadatas: Set<EditableMetadata>
        
        func set(_ value: V) {
            metadatas.forEach { $0.metadata[keyPath: keyPath] = value }
        }
    }
    
    var id: URL { url }
    let url: URL
    
    @State var metadata: Metadata
    @State private(set) var initialMetadata: Metadata
    
    init(url: URL, metadata: Metadata) {
        self.url = url
        self.metadata = metadata
        self.initialMetadata = metadata
    }
    
    init(item: PlaylistItem) {
        self.init(url: item.url, metadata: item.metadata)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    func revert() {
        metadata = initialMetadata
    }
    
    func apply() {
        initialMetadata = metadata
    }
    
    subscript<V>(extracting keyPath: WritableKeyPath<Metadata, V>) -> Values<V> {
        .init(keyPath: keyPath, metadata: self)
    }
}

extension EditableMetadata: Equatable {
    static func == (lhs: EditableMetadata, rhs: EditableMetadata) -> Bool {
        lhs.id == rhs.id
    }
}

enum MetadataValueState<V> {
    case undefined(EditableMetadata.Setter<V>)
    case fine(EditableMetadata.Values<V>)
    case varied(EditableMetadata.Setter<V>)
}

@Observable class MetadataEditingModel: Identifiable {
    let id: UUID = .init()
    
    var metadatas: Set<EditableMetadata> = .init()
    
    func update(items: [PlaylistItem]) {
        metadatas = .init(items.map { .init(item: $0) })
    }
    
    subscript<V: Equatable>(extracting keyPath: WritableKeyPath<Metadata, V>) -> MetadataValueState<V> {
        let setter = EditableMetadata.Setter(keyPath: keyPath, metadatas: metadatas)
        guard !metadatas.isEmpty else { return .undefined(setter) }
        
        let values = metadatas
            .map { $0[extracting: keyPath] }
        let areIdentical = values.allSatisfy { $0.current == values[0].current }
        
        return areIdentical ? .fine(values[0]) : .varied(setter)
    }
}
