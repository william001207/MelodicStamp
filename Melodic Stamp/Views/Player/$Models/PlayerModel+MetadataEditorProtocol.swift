//
//  PlayerModel+MetadataEditorProtocol.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/26.
//

import Foundation

extension PlayerModel: MetadataEditorProtocol {
    var metadataSet: Set<Metadata> {
        Set(playlist.map(\.metadata).filter(\.state.isInitialized))
    }
}
