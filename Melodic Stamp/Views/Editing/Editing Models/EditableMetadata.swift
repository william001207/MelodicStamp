//
//  EditableMetadata.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/11/24.
//

@preconcurrency import CSFBAudioEngine
import SwiftUI

@Observable final class EditableMetadata: Identifiable, Sendable {
    struct Value<V: Equatable>: Equatable {
        let keyPath: WritableKeyPath<Metadata, V>
        let metadatas: Set<EditableMetadata>
        
        var current: V {
            get { metadatas.first!.current[keyPath: keyPath] }
            nonmutating set { metadatas.forEach { $0.current[keyPath: keyPath] = newValue } }
        }
        
        private(set) var initial: V {
            get { metadatas.first!.initial[keyPath: keyPath] }
            nonmutating set { metadatas.forEach { $0.initial[keyPath: keyPath] = newValue } }
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
        
        subscript<S: Equatable>(isModified keyPath: KeyPath<V, S>) -> Bool {
            current[keyPath: keyPath] != initial[keyPath: keyPath]
        }
    }
    
    struct Values<V: Equatable & Hashable>: Equatable {
        let keyPath: WritableKeyPath<Metadata, V>
        let metadatas: Set<EditableMetadata>
        
        var values: [Value<V>] {
            metadatas.map { $0[extracting: keyPath] }
        }
        
        var isModified: Bool {
            !values.filter(\.isModified).isEmpty
        }
        
        func revertAll() {
            values.forEach { $0.revert() }
        }
        
        func applyAll() {
            values.forEach { $0.apply() }
        }
        
        subscript<S: Equatable>(isModified keyPath: KeyPath<V, S>) -> Bool {
            !values.filter(\.[isModified: keyPath]).isEmpty
        }
    }

    enum State {
        case loading
        case fine
        case saving

        var isEditable: Bool {
            switch self {
            case .fine:
                true
            default:
                false
            }
        }

        var isLoaded: Bool {
            switch self {
            case .loading:
                false
            default:
                true
            }
        }
    }

    var id: URL { url }
    let url: URL

    let properties: AudioProperties
    var current: Metadata
    private(set) var initial: Metadata

    private(set) var state: State = .loading

    init?(url: URL) {
        self.url = url
        current = .init()
        initial = .init()
        properties = .init()

        Task.detached {
            try await self.update()
            self.state = .fine
        }
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
                self.state = .fine
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
            guard let self, self.state.isEditable && self.isModified else { return continuation.resume() }
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

    subscript<V>(extracting keyPath: WritableKeyPath<Metadata, V>) -> Value<V> {
        .init(keyPath: keyPath, metadatas: [self])
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
