//
//  URL+Extensions.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/25.
//

import Foundation

extension URL {
    var isFileExist: Bool {
        guard isFileURL else { return false }
        return FileManager.default.fileExists(atPath: path)
    }

    var isFileReadOnly: Bool {
        guard isFileURL else { return false }
        return FileManager.default.isWritableFile(atPath: path) == false
    }
}

extension URL {
    func canAccessSecurityScopedResourceOrIsReachable() -> Bool {
        let isReachable = (try? checkResourceIsReachable()) ?? false
        return startAccessingSecurityScopedResource() || isReachable
    }

    func attribute(_ key: FileAttributeKey) throws -> Any? {
        try FileManager.default.attributesOfItem(atPath: path(percentEncoded: false))[key]
    }
}
