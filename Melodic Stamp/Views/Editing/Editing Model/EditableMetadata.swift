//
//  EditableMetadata.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/11/24.
//

import SwiftUI
@preconcurrency import CSFBAudioEngine

@Observable final class EditableMetadata: Identifiable, Sendable {
    struct Values<V: Equatable> {
        let keyPath: WritableKeyPath<Metadata, V>
        let metadata: EditableMetadata
        
        var current: V {
            get { metadata.current[keyPath: keyPath] }
            nonmutating set { metadata.current[keyPath: keyPath] = newValue }
        }
        
        private(set) var initial: V {
            get { metadata.initial[keyPath: keyPath] }
            nonmutating set { metadata.initial[keyPath: keyPath] = newValue }
        }
        
        var projectedValue: Binding<V> {
            Binding(get: {
                current
            }, set: { newValue in
                current = newValue
            })
        }
        
        var isModified: Bool {
            current != initial
        }
        
        func revert() {
            current = initial
        }
        
        func apply() {
            initial = current
        }
    }
    
    struct ValueSetter<V> {
        let keyPath: WritableKeyPath<Metadata, V>
        let editableMetadatas: Set<EditableMetadata>
        
        func set(_ value: V) {
            editableMetadatas.forEach { $0.current[keyPath: keyPath] = value }
        }
    }
    
    var id: URL { url }
    let url: URL
    
    let properties: AudioProperties
    var current: Metadata
    private(set) var initial: Metadata
    
    init?(url: URL) {
        guard url.startAccessingSecurityScopedResource() else { return nil }
        defer { url.stopAccessingSecurityScopedResource() }
        
        self.url = url
        
        guard let audioFile = try? AudioFile(readingPropertiesAndMetadataFrom: url) else { return nil }
        let metadata = Metadata(from: audioFile.metadata)
        self.current = metadata
        self.initial = metadata
        
        self.properties = audioFile.properties
    }
    
    var isModified: Bool {
        current != initial
    }
    
    func revert() {
        current = initial
    }
    
    func apply() {
        initial = current
    }
    
    func write() async throws -> AsyncThrowingStream<Void, Error> {
        .init { continuation in
            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let self, self.isModified else { return }
                guard self.url.startAccessingSecurityScopedResource() else { return }
                defer { self.url.stopAccessingSecurityScopedResource() }
                
                do {
                    print("Started writing metadata to \(self.url)")
                    let file = try AudioFile(url: self.url)
                    file.metadata = self.current.packed
                    try file.writeMetadata()
                    
                    print("Successfully written metadata to \(self.url)")
                    self.initial = self.current
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
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

extension EditableMetadata: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
