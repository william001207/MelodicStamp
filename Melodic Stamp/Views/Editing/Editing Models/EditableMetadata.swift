//
//  EditableMetadata.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/11/24.
//

@preconcurrency import CSFBAudioEngine
import SwiftUI

@Observable final class EditableMetadata: Identifiable, Sendable {
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
    fileprivate(set) var initial: Metadata

    private(set) var state: State = .loading

    init?(url: URL) {
        self.url = url
        self.current = .init()
        self.initial = .init()
        self.properties = .init()

        Task.detached {
            try await self.update()
            self.state = .fine
        }
    }
}

extension EditableMetadata {
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
        try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self else { return continuation.resume() }
            guard url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }

            do {
                let file = try AudioFile(readingPropertiesAndMetadataFrom: url)
                state = .fine
                current = .init(from: file.metadata)
                initial = current
                print("Updated metadata from \(url)")

                continuation.resume()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    func write() async throws {
        try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self, state.isEditable, isModified else { return continuation.resume() }
            guard url.startAccessingSecurityScopedResource() else { return }
            defer { self.url.stopAccessingSecurityScopedResource() }

            do {
                state = .saving
                initial = current
                print("Started writing metadata to \(url)")

                let file = try AudioFile(url: url)
                file.metadata = current.packed
                try file.writeMetadata()

                apply()
                state = .fine
                print("Successfully written metadata to \(url)")

                continuation.resume()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    subscript<V>(extracting keyPath: WritableKeyPath<Metadata, V>) -> BatchEditableMetadataValue<V> {
        .init(keyPath: keyPath, editableMetadatas: [self])
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

@Observable final class BatchEditableMetadataValue<V: Equatable>: Identifiable {
    let keyPath: WritableKeyPath<Metadata, V>
    let editableMetadatas: Set<EditableMetadata>
    
    private var temporary: V?
    private var updateDispatch: DispatchWorkItem?

    init(keyPath: WritableKeyPath<Metadata, V>, editableMetadatas: Set<EditableMetadata>) {
        self.keyPath = keyPath
        self.editableMetadatas = editableMetadatas
    }

    var current: V {
        get {
            if let temporary {
                print("Batch editing temporary value \(temporary)")
                return temporary
            } else {
                let temporary = get()
                self.temporary = temporary
                print("Initializing batch editable temporary value \(temporary)")
                return temporary
            }
        }

        set {
            temporary = newValue
            let updateDispatch = DispatchWorkItem { [weak self] in
                guard let self else { return }
                self.set(newValue)
                self.temporary = nil
                print("Batch edited value to \(newValue)")
            }
            
            // debounce after 0.5s
            self.updateDispatch?.cancel()
            self.updateDispatch = updateDispatch
            DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + 0.5, execute: updateDispatch)
        }
    }

    private(set) var initial: V {
        get {
            editableMetadatas.first!.initial[keyPath: keyPath]
        }

        set {
            editableMetadatas.forEach { $0.initial[keyPath: keyPath] = newValue }
        }
    }

    var projectedValue: Binding<V> {
        Binding(get: {
            self.current
        }, set: { newValue in
            self.current = newValue
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
    
    private func get() -> V {
        editableMetadatas.first!.current[keyPath: keyPath]
    }
    
    private func set(_ value: V) {
        editableMetadatas.forEach { $0.current[keyPath: self.keyPath] = value }
    }

    subscript(isModified keyPath: KeyPath<V, some Equatable>) -> Bool {
        current[keyPath: keyPath] != initial[keyPath: keyPath]
    }
}

@Observable final class BatchEditableMetadataValues<V: Equatable>: Identifiable {
    let keyPath: WritableKeyPath<Metadata, V>
    let editableMetadatas: Set<EditableMetadata>

    init(keyPath: WritableKeyPath<Metadata, V>, editableMetadatas: Set<EditableMetadata>) {
        self.keyPath = keyPath
        self.editableMetadatas = editableMetadatas
    }

    var values: [BatchEditableMetadataValue<V>] {
        editableMetadatas.map { $0[extracting: keyPath] }
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

    subscript(isModified keyPath: KeyPath<V, some Equatable>) -> Bool {
        !values.filter(\.[isModified: keyPath]).isEmpty
    }
}
