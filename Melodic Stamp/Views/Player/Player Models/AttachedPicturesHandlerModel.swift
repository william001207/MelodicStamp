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
    
    func replacingAndAddingAttachedPictures(
        _ newAttachedPictures: [AttachedPicture],
        in attachedPictures: Set<AttachedPicture>
    ) -> Set<AttachedPicture> {
        let types = newAttachedPictures.map(\.type)
        let removed = attachedPictures.filter { !types.contains($0.type) }
        return removed.union(newAttachedPictures)
    }
    
    func replacingAndAddingAttachedPictures(
        _ newAttachedPictures: [AttachedPicture],
        state: MetadataValueState<Set<AttachedPicture>>
    ) {
        switch state {
        case .undefined:
            break
        case .fine(let value):
            value.current = replacingAndAddingAttachedPictures(newAttachedPictures, in: value.current)
        case .varied(let values):
            values.current = values.current.mapValues { attachedPictures in
                replacingAndAddingAttachedPictures(newAttachedPictures, in: attachedPictures)
            }
        }
    }
    
    func removingAttachedPictures(
        of types: [AttachedPicture.`Type`]? = nil,
        in attachedPictures: Set<AttachedPicture>
    ) -> Set<AttachedPicture> {
        if let types {
            attachedPictures.filter { !types.contains($0.type) }
        } else {
            []
        }
    }
    
    func removingAttachedPictures(
        of types: [AttachedPicture.`Type`]? = nil,
        state: MetadataValueState<Set<AttachedPicture>>
    ) {
        switch state {
        case .undefined:
            break
        case .fine(let value):
            value.current = removingAttachedPictures(of: types, in: value.current)
        case .varied(let values):
            values.current = values.current.mapValues { attachedPictures in
                removingAttachedPictures(of: types, in: attachedPictures)
            }
        }
    }
}
