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
    typealias Value = EditableMetadata.Value<Set<AttachedPicture>>
    typealias State = MetadataValueState<Set<AttachedPicture>>

    static var allowedContentTypes: [UTType] {
        [.jpeg, .png, .tiff, .bmp, .gif, .heic, .heif, .rawImage]
    }

    private func isModified(of types: [APType]? = nil, value: Value, countAsEmpty fallback: Bool = true) -> Bool {
        guard let types else { return false }
        return !value.current
            .filter { types.contains($0.type) }
            .filter { currentValue in
                guard
                    let initialValue = value.initial.filter({
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
        case .fine(let value):
            isModified(of: types, value: value, countAsEmpty: fallback)
        case .varied(let values):
            !values.values
                .filter { isModified(of: types, value: $0, countAsEmpty: fallback) }
                .isEmpty
        }
    }

    func types(state: State) -> Set<APType> {
        switch state {
        case .undefined:
            []
        case .fine(let value):
            Set(value.current.map(\.type))
        case .varied(let values):
            Set(values.values.flatMap(\.current).map(\.type))
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

    private func replace(_ newAttachedPictures: [AttachedPicture], value: Value)
    {
        value.current = replacing(newAttachedPictures, in: value.current)
    }

    func replace(_ newAttachedPictures: [AttachedPicture], state: State) {
        switch state {
        case .undefined:
            break
        case .fine(let value):
            replace(newAttachedPictures, value: value)
        case .varied(let values):
            values.values.forEach { replace(newAttachedPictures, value: $0) }
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

    private func remove(of types: [APType]? = nil, value: Value) {
        value.current = removing(of: types, in: value.current)
    }

    func remove(of types: [APType]? = nil, state: State) {
        switch state {
        case .undefined:
            break
        case .fine(let value):
            remove(of: types, value: value)
        case .varied(let values):
            values.values.forEach { remove(of: types, value: $0) }
        }
    }

    private func revert(of types: [APType]? = nil, value: Value) {
        guard let types else {
            value.revert()
            return
        }

        let initialAttachedPictures: [AttachedPicture] = value.initial.filter {
            types.contains($0.type)
        }

        if initialAttachedPictures.isEmpty {
            remove(of: types, value: value)
        } else {
            replace(initialAttachedPictures, value: value)
        }
    }

    func revert(of types: [APType]? = nil, state: State) {
        guard let types else {
            switch state {
            case .undefined:
                break
            case .fine(let value):
                value.revert()
            case .varied(let values):
                values.revertAll()
            }
            return
        }

        switch state {
        case .undefined:
            break
        case .fine(let value):
            revert(of: types, value: value)
        case .varied(let values):
            values.values.forEach { revert(of: types, value: $0) }
        }
    }
}
