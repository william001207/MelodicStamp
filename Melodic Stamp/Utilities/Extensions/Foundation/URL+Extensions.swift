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

    var lastPathComponentRemovingExtension: String {
        let pathExtensionCount: Int = if pathExtension.isEmpty {
            .zero
        } else {
            pathExtension.count + 1
        }

        return String(lastPathComponent.dropLast(pathExtensionCount))
    }
}

extension URL {
    func canAccessSecurityScopedResourceOrIsReachable() -> Bool {
        let isReachable = (try? checkResourceIsReachable()) ?? false
        return startAccessingSecurityScopedResource() || isReachable
    }
}
