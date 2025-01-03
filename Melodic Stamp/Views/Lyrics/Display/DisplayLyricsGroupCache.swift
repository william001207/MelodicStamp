//
//  DisplayLyricsGroupCache.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/3.
//

import SwiftUI

final class DisplayLyricsGroupCache {
    typealias Key = [AnyHashable]
    typealias Value = [AnyHashable: [Text.Layout.RunSlice]]
    typealias Identifier = AnyHashable

    nonisolated(unsafe) static var shared = DisplayLyricsGroupCache()

    var groups: [Key: (identifier: Identifier, value: Value)]
    
    init(groups: [Key : (identifier: Identifier, value: Value)] = [:]) {
        self.groups = groups
    }

    func contains(key: [some AnimatedString]) -> Bool {
        let hashableKey = key.map(\.self)
        return groups.keys.contains(hashableKey)
    }

    func get<Animated>(
        key: [Animated],
        identifiedBy identifier: Identifier
    ) -> [Animated: [Text.Layout.RunSlice]]? where Animated: AnimatedString {
        let hashableKey = key.map(\.self)
        guard let pair = groups[hashableKey] else { return nil }

        guard pair.identifier == identifier else { return nil }
        return pair.value as? [Animated: [Text.Layout.RunSlice]]
    }

    func set<Animated>(
        key: [Animated], value: [Animated: [Text.Layout.RunSlice]],
        identifiedBy identifier: Identifier
    ) where Animated: AnimatedString {
        let hashableKey = key.map(\.self)
        groups[hashableKey] = (identifier, value)
    }
}
