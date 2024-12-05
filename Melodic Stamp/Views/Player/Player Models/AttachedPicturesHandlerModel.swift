//
//  AttachedPicturesHandlerModel.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/1.
//

import CSFBAudioEngine
import SwiftUI
import UniformTypeIdentifiers

@Observable class AttachedPicturesHandlerModel {
    typealias APType = AttachedPicture.`Type`
    typealias Entry = MetadataBatchEditingEntry<Set<AttachedPicture>>
    typealias State = MetadataValueState<Set<AttachedPicture>>

    static var allowedContentTypes: [UTType] {
        [.jpeg, .png, .tiff, .bmp, .gif, .heic, .heif, .rawImage]
    }

    private func isModified(of types: [APType]? = nil, entry: Entry, countAsEmpty fallback: Bool = true) -> Bool {
        guard let types else { return false }
        return !entry.current
            .filter { types.contains($0.type) }
            .filter { currentValue in
                guard
                    let initialValue = entry.initial.filter({
                        $0.type == currentValue.type
                    }).first
                else { return fallback }
                return currentValue != initialValue
            }
            .isEmpty
    }

    func isModified(of types: [APType]? = nil, state: State, countAsEmpty fallback: Bool = true) -> Bool {
        switch state {
        case .undefined:
            false
        case let .fine(entry):
            isModified(of: types, entry: entry, countAsEmpty: fallback)
        case let .varied(entries):
            !entries
                .filter { isModified(of: types, entry: $0, countAsEmpty: fallback) }
                .isEmpty
        }
    }

    func types(state: State) -> Set<APType> {
        switch state {
        case .undefined:
            []
        case let .fine(entry):
            Set(entry.current.map(\.type))
        case let .varied(entries):
            Set(entries.flatMap(\.current).map(\.type))
        }
    }

    func replacing(
        _ newAttachedPictures: [AttachedPicture],
        in attachedPictures: Set<AttachedPicture>
    ) -> Set<AttachedPicture> {
        let types = newAttachedPictures.map(\.type)
        let removed = attachedPictures.filter { !types.contains($0.type) }
        return removed.union(newAttachedPictures)
    }

    private func replace(_ newAttachedPictures: [AttachedPicture], entry: Entry) {
        entry.current = replacing(newAttachedPictures, in: entry.current)
    }

    func replace(_ newAttachedPictures: [AttachedPicture], state: State) {
        switch state {
        case .undefined:
            break
        case let .fine(entry):
            replace(newAttachedPictures, entry: entry)
        case let .varied(entries):
            entries.forEach { replace(newAttachedPictures, entry: $0) }
        }
    }

    func removing(
        of types: [APType]? = nil, in attachedPictures: Set<AttachedPicture>
    ) -> Set<AttachedPicture> {
        if let types {
            attachedPictures.filter { !types.contains($0.type) }
        } else {
            []
        }
    }

    private func remove(of types: [APType]? = nil, entry: Entry) {
        entry.current = removing(of: types, in: entry.current)
    }

    func remove(of types: [APType]? = nil, state: State) {
        switch state {
        case .undefined:
            break
        case let .fine(entry):
            remove(of: types, entry: entry)
        case let .varied(entries):
            entries.forEach { remove(of: types, entry: $0) }
        }
    }

    private func restore(of types: [APType]? = nil, entry: Entry) {
        guard let types else {
            entry.restore()
            return
        }

        let initialAttachedPictures: [AttachedPicture] = entry.initial.filter {
            types.contains($0.type)
        }

        if initialAttachedPictures.isEmpty {
            remove(of: types, entry: entry)
        } else {
            replace(initialAttachedPictures, entry: entry)
        }
    }

    func restore(of types: [APType]? = nil, state: State) {
        guard let types else {
            switch state {
            case .undefined:
                break
            case let .fine(entry):
                entry.restore()
            case let .varied(entries):
                entries.revertAll()
            }
            return
        }

        switch state {
        case .undefined:
            break
        case let .fine(entry):
            restore(of: types, entry: entry)
        case let .varied(entries):
            entries.forEach { restore(of: types, entry: $0) }
        }
    }
}
