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
    static var allowedContentTypes: [UTType] {
        [.jpeg, .png, .tiff, .bmp, .gif, .heic, .heif, .rawImage]
    }
    
    func types(state: MetadataValueState<Set<AttachedPicture>>) -> Set<AttachedPicture.`Type`> {
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
        state: MetadataValueState<Set<AttachedPicture>>
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
        of types: [AttachedPicture.`Type`]? = nil,
        in attachedPictures: Set<AttachedPicture>
    ) -> Set<AttachedPicture> {
        if let types {
            attachedPictures.filter { !types.contains($0.type) }
        } else {
            []
        }
    }
    
    func remove(
        of types: [AttachedPicture.`Type`]? = nil,
        state: MetadataValueState<Set<AttachedPicture>>
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
        of types: [AttachedPicture.`Type`]? = nil,
        state: MetadataValueState<Set<AttachedPicture>>
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
            replace(value.initial.filter({ types.contains($0.type) }), state: state)
        case .varied(let values):
            values.current.keys.forEach { key in
                let value = values.initial[key] ?? []
                replace(value.filter({ types.contains($0.type) }), state: state)
            }
        }
    }
}
