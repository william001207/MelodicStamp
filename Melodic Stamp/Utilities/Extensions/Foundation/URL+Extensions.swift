//
//  URL+Extensions.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/25.
//

import Foundation

extension URL {
    var isFileReadOnly: Bool {
        guard isFileURL else { return false }
        return FileManager.default.isWritableFile(atPath: path) == false
    }
}
