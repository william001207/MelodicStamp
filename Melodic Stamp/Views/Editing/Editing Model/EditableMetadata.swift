//
//  EditableMetadata.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/11/24.
//

import SwiftUI
@preconcurrency import CSFBAudioEngine

@Observable final class EditableMetadata: Identifiable, Sendable {
    struct Values<V: Equatable>: Equatable {
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
    
    struct ValueSetter<V>: Equatable {
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
    
    init?(url: URL) async throws {
        self.url = url
        self.current = .init()
        self.initial = .init()
        self.properties = .init()
        
        try await self.update()
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
    
    func update() async throws {
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self else { return continuation.resume() }
            guard url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }
            
            do {
                let file = try AudioFile(readingPropertiesAndMetadataFrom: url)
                self.current = .init(from: file.metadata)
                self.initial = self.current
                print("Updated metadata from \(self.url)")
                
                continuation.resume()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    func write() async throws {
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self, self.isModified else { return continuation.resume() }
            guard self.url.startAccessingSecurityScopedResource() else { return }
            defer { self.url.stopAccessingSecurityScopedResource() }
            
            do {
                self.state = .saving
                self.initial = self.current
                print("Started writing metadata to \(self.url)")
                
                let file = try AudioFile(url: self.url)
                file.metadata = self.current.packed
                try file.writeMetadata()
                
                self.state = .fine
                print("Successfully written metadata to \(self.url)")
                
                continuation.resume()
            } catch {
                continuation.resume(throwing: error)
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
