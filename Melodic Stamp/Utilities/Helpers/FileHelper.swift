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
        guard folderURL.startAccessingSecurityScopedResource() else { return [] }
        guard folderURL.hasDirectoryPath else { return [folderURL] }

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

            return if let url = filter(url: url) {
                [url]
            } else { [] }
        }
    }

    static func filter(url: URL) -> URL? {
        guard url.isFileURL else { return nil }

        let resourceValues = try? url.resourceValues(forKeys: [.contentTypeKey])
        guard let fileType = resourceValues?.contentType else { return nil }

        return allowedContentTypes.contains(fileType) ? url : nil
    }
}
