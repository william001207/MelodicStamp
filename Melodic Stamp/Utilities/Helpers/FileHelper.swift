//
//  FileHelper.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/17.
//

import Foundation
import UniformTypeIdentifiers

enum FileHelper {
    static func flatten(contentsOfFolder folderURL: URL, allowedContentTypes: [UTType], isRecursive: Bool = true) -> [URL] {
        guard folderURL.hasDirectoryPath else { return [folderURL] }
        guard folderURL.startAccessingSecurityScopedResource() else { return [] }

        let fileManager = FileManager.default
        guard let contents = try? fileManager.contentsOfDirectory(
            at: folderURL,
            includingPropertiesForKeys: [.isRegularFileKey, .isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else { return [] }

        return contents.flatMap { url in
            guard url.isFileURL else {
                return flatten(contentsOfFolder: url, allowedContentTypes: allowedContentTypes, isRecursive: isRecursive)
            }

            let resourceValues = try? url.resourceValues(forKeys: [.contentTypeKey])
            guard let fileType = resourceValues?.contentType else { return [URL]() }

            return allowedContentTypes.contains(fileType) ? [url] : [URL]()
        }
    }
}
