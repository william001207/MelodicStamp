//
//  MetadataEntry.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/5.
//

import SwiftUI

// MARK: - Modifiable

protocol Modifiable {
    var isModified: Bool { get }
}

// MARK: - Restorable

protocol Restorable: Equatable, Modifiable {
    associatedtype V: Equatable

    var current: V { get set }
    var initial: V { get set }

    mutating func restore()
    mutating func apply()
}

extension Restorable {
    var isModified: Bool {
        current != initial
    }

    mutating func restore() {
        current = initial
    }

    mutating func apply() {
        initial = current
    }
}

// MARK: - Metadata Entry

@Observable final class MetadataEntry<V: Hashable & Equatable>: Restorable {
    var current: V
    var initial: V

    init(_ value: V) {
        self.current = value
        self.initial = value
    }
}

extension MetadataEntry: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(current)
        hasher.combine(initial)
    }
}

extension MetadataEntry: Equatable {
    static func == (lhs: MetadataEntry<V>, rhs: MetadataEntry<V>) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

// MARK: - Metadata Batch Editing Entry

@Observable
final class MetadataBatchEditingEntry<V: Hashable & Equatable>: Identifiable {
    typealias Entry = MetadataEntry
    typealias EntryKeyPath = WritableKeyPath<Metadata, Entry<V>>

    let keyPath: EntryKeyPath
    let metadatas: Set<Metadata>

    init(keyPath: EntryKeyPath, metadatas: Set<Metadata>) {
        self.keyPath = keyPath
        self.metadatas = metadatas
    }

    var current: V {
        get {
            metadatas.first![keyPath: keyPath].current
        }

        set {
            metadatas.forEach { $0[keyPath: keyPath].current = newValue }
        }
    }

    private(set) var initial: V {
        get {
            metadatas.first![keyPath: keyPath].initial
        }

        set {
            metadatas.forEach { $0[keyPath: keyPath].initial = newValue }
        }
    }

    var projectedValue: Binding<V> {
        Binding(
            get: {
                self.current
            },
            set: { newValue in
                self.current = newValue
            }
        )
    }

    var isModified: Bool {
        current != initial
    }

    func restore() {
        current = initial
    }

    func apply() {
        initial = current
    }

    subscript(isModified keyPath: KeyPath<V, some Equatable>) -> Bool {
        current[keyPath: keyPath] != initial[keyPath: keyPath]
    }
}

extension MetadataBatchEditingEntry: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(keyPath)
        hasher.combine(metadatas)
    }
}

extension MetadataBatchEditingEntry: Equatable {
    static func == (lhs: MetadataBatchEditingEntry<V>, rhs: MetadataBatchEditingEntry<V>) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

// MARK: - Metadata Batch Editing Entries

@Observable final class MetadataBatchEditingEntries<V: Hashable & Equatable>: Identifiable {
    typealias Entry = MetadataEntry
    typealias EntryKeyPath = WritableKeyPath<Metadata, Entry<V>>

    let keyPath: EntryKeyPath
    let metadatas: Set<Metadata>

    init(keyPath: EntryKeyPath, metadatas: Set<Metadata>) {
        self.keyPath = keyPath
        self.metadatas = metadatas
    }

    var isModified: Bool {
        !filter(\.isModified).isEmpty
    }

    func revertAll() {
        forEach { $0.restore() }
    }

    func applyAll() {
        forEach { $0.apply() }
    }

    subscript(isModified keyPath: KeyPath<V, some Equatable>) -> Bool {
        !filter(\.[isModified: keyPath]).isEmpty
    }
}

extension MetadataBatchEditingEntries: Sequence {
    func makeIterator() -> Array<MetadataBatchEditingEntry<V>>.Iterator {
        metadatas.map { $0[extracting: keyPath] }.makeIterator()
    }
}

extension MetadataBatchEditingEntries: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(keyPath)
        hasher.combine(metadatas)
    }
}

extension MetadataBatchEditingEntries: Equatable {
    static func == (lhs: MetadataBatchEditingEntries<V>, rhs: MetadataBatchEditingEntries<V>) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
