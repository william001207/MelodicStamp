//
//  PlaylistItem.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/20.
//

import Foundation
import AppKit
import CSFBAudioEngine

struct PlaylistItem: Identifiable {
    let id = UUID()
    let url: URL
    var properties: AudioProperties
    @Watched var metadata: AudioMetadata

    init?(_ url: URL) {
        guard url.startAccessingSecurityScopedResource() else { return nil }
        defer { url.stopAccessingSecurityScopedResource() }
        
        self.url = url
        if let audioFile = try? AudioFile(readingPropertiesAndMetadataFrom: url) {
            self.properties = audioFile.properties
            self.metadata = audioFile.metadata
        } else {
            self.properties = .init()
            self.metadata = .init()
        }
    }
    
    var initialMetadata: AudioMetadata {
        _metadata.initialValue
    }

    func decoder(enableDoP: Bool = false) throws -> PCMDecoding? {
        guard url.startAccessingSecurityScopedResource() else { return nil }
        defer { url.stopAccessingSecurityScopedResource() }
        
        let pathExtension = url.pathExtension.lowercased()
        if AudioDecoder.handlesPaths(withExtension: pathExtension) {
            return try AudioDecoder(url: url)
        } else if DSDDecoder.handlesPaths(withExtension: pathExtension) {
            let dsdDecoder = try DSDDecoder(url: url)
            return enableDoP ? try DoPDecoder(decoder: dsdDecoder) : try DSDPCMDecoder(decoder: dsdDecoder)
        }
        
        return nil
    }
    
    func revertMetadata() {
        _metadata.revert()
    }
    
    func reinitMetadata() {
        _metadata.reinit()
    }
    
    func reinitMetadata(with metadata: AudioMetadata) {
        _metadata.reinit(with: metadata)
    }
    
    func writeMetadata(_ operation: (inout AudioMetadata) -> Void = { _ in }) {
        do {
            guard url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }
            
            let file = try AudioFile(url: url)
            file.metadata = metadata
            operation(&file.metadata)
            try file.writeMetadata()
            
            print("Successfully written metadata to \(url)")
            reinitMetadata()
        } catch {
            
        }
    }
}

extension PlaylistItem: Equatable {
    static func ==(lhs: PlaylistItem, rhs: PlaylistItem) -> Bool {
        lhs.id == rhs.id
    }
}

extension PlaylistItem: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
