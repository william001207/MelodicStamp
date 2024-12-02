//
//  AttachedPicturesHandlerModel.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/1.
//

import SwiftUI
import UniformTypeIdentifiers
import CSFBAudioEngine

@Observable class AttachedPicturesHandlerModel {
    typealias APType = AttachedPicture.`Type`
    typealias State = MetadataValueState<Set<AttachedPicture>>
    
    static var allowedContentTypes: [UTType] {
        [.jpeg, .png, .tiff, .bmp, .gif, .heic, .heif, .rawImage]
    }
    
    func isModified(
        of types: [APType]? = nil,
        state: State
    ) -> Bool {
        guard let types else { return false }
        return switch state {
        case .undefined:
            false
        case .fine(let value):
            !value.current
                .filter { types.contains($0.type) }
                .filter { currentValue in
                    guard let initialValue = value.initial.filter({ $0.type == currentValue.type }).first else { return false }
                    return currentValue != initialValue
                }
                .isEmpty
        case .varied(let values):
            values.current.values
                .filter { currentValues in
                    currentValues
                        .filter { types.contains($0.type) }
                        .filter { currentValue in
                            guard let initialValue =
                        }
                }
        }
    }
    
    func types(state: State) -> Set<APType> {
        switch state {
        case .undefined:
            []
        case .fine(let value):
            Set(value.current.map(\.type))
        case .varied(let values):
            Set(values.current.values.flatMap(\.self).map(\.type))
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
    
    func replace(
        _ newAttachedPictures: [AttachedPicture],
        state: State
    ) {
        switch state {
        case .undefined:
            break
        case .fine(let value):
            value.current = replacing(newAttachedPictures, in: value.current)
        case .varied(let values):
            values.current = values.current.mapValues { attachedPictures in
                replacing(newAttachedPictures, in: attachedPictures)
            }
        }
    }
    
    func removing(
        of types: [APType]? = nil,
        in attachedPictures: Set<AttachedPicture>
    ) -> Set<AttachedPicture> {
        if let types {
            attachedPictures.filter { !types.contains($0.type) }
        } else {
            []
        }
    }
    
    func remove(
        of types: [APType]? = nil,
        state: State
    ) {
        switch state {
        case .undefined:
            break
        case .fine(let value):
            value.current = removing(of: types, in: value.current)
        case .varied(let values):
            values.current = values.current.mapValues { attachedPictures in
                removing(of: types, in: attachedPictures)
            }
        }
    }
    
    func revert(
        of types: [APType]? = nil,
        state: State
    ) {
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
            let initialAttachedPictures: [AttachedPicture] = value.initial.filter { types.contains($0.type) }
            
            if initialAttachedPictures.isEmpty {
                remove(of: types, state: state)
            } else {
                replace(initialAttachedPictures, state: state)
            }
        case .varied(let values):
            values.current.keys.forEach { key in
                let initialValue = values.initial[key] ?? []
                let initialAttachedPictures: [AttachedPicture] = initialValue.filter { types.contains($0.type) }
                
                if initialAttachedPictures.isEmpty {
                    remove(of: types, state: state)
                } else {
                    replace(initialAttachedPictures, state: state)
                }
            }
        }
    }
}
