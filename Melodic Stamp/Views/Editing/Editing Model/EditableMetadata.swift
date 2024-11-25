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
    
    enum State {
        case fine
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
    
    var id: URL { url }
    let url: URL
    
    let properties: AudioProperties
    var current: Metadata
    private(set) var initial: Metadata
    
    var state: State = .fine
    
    static func read(url: URL) throws -> AudioFile? {
        try? AudioFile(readingPropertiesAndMetadataFrom: url)
    }
    
    init?(url: URL) throws {
        guard url.startAccessingSecurityScopedResource() else { return nil }
        defer { url.stopAccessingSecurityScopedResource() }
        
        self.url = url
        self.current = .init()
        self.initial = .init()
        self.properties = .init()
        
        try self.update()
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
    
    func update() throws {
        guard let file = try Self.read(url: url) else { return }
        let metadata = Metadata(from: file.metadata)
        self.current = metadata
        self.initial = metadata
        print("Updated metadata from \(self.url)")
    }
    
    func write() async throws -> AsyncThrowingStream<Void, Error> {
        .init { continuation in
            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let self, self.isModified else { return }
                guard self.url.startAccessingSecurityScopedResource() else { return }
                defer { self.url.stopAccessingSecurityScopedResource() }
                
                do {
                    print("Started writing metadata to \(self.url)")
                    self.state = .saving
                    
                    let file = try AudioFile(url: self.url)
                    self.current.pack(&file.metadata)
                    try file.writeMetadata()
                    
                    print("Successfully written metadata to \(self.url)")
                    try self.update()
                    self.state = .fine
                    
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
