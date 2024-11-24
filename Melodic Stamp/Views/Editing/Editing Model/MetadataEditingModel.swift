//
//  MetadataEditingModel.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/24.
//

import SwiftUI
import CSFBAudioEngine

struct EditableMetadata: Identifiable {
    typealias Values = (initial: Any, current: Any)
    
    var id: URL { url }
    let url: URL
    
    @State var metadata: Metadata
    @State private(set) var initialMetadata: Metadata
    
    init(url: URL, metadata: Metadata) {
        self.url = url
        self.metadata = metadata
        self.initialMetadata = metadata
    }
    
    func revert() {
        metadata = initialMetadata
    }
    
    func apply() {
        initialMetadata = metadata
    }
    
    subscript(_ key: AudioMetadata.Key) -> Values {
        (self.initialMetadata[keyPath: key.keyPath], self.metadata[keyPath: key.keyPath])
    }
}

enum MetadataValueState {
    case undefined
    case fine(Any)
    case varied
}

@Observable class MetadataEditingModel: Identifiable {
    let id: UUID = .init()
    
    var metadatas: [EditableMetadata] = []
    
    private func areAllElementsIdentical(_ array: [Any]) -> Bool {
        guard let first = array.first else { return true }
        
        for element in array {
            let firstRef = first as AnyObject
            let elementRef = element as AnyObject
            
            if firstRef !== elementRef {
                return false
            }
        }
        return true
    }
    
    subscript(_ key: AudioMetadata.Key) -> MetadataValueState {
        guard !metadatas.isEmpty else { return .undefined }
        let values = metadatas
            .map { $0[key] }
            .map(\.current)
        let areIdentical = areAllElementsIdentical(values)
        return areIdentical ? .fine(values[0]) : .varied
    }
}
