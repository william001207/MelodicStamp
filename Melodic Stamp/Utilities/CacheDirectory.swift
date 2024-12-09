//
//  CacheDirectory.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/9.
//

import Foundation

enum CacheDirectory: String, Hashable, Equatable, Identifiable, CaseIterable, Codable {
    case imageCache = "ImageCache"
    
    var id: String { rawValue }
    
    var url: URL {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent(rawValue)
    }
    
    func file(at path: String) -> URL {
        url.appending(path: path, directoryHint: .notDirectory)
    }
    
    func create() async throws {
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
    }
    
    func remove() async throws {
        try FileManager.default.removeItem(at: url)
    }
    
    func hasData(at path: String) -> Bool {
        FileManager.default.fileExists(atPath: file(at: path).path())
    }
    
    func write(_ data: Data, to path: String) async throws {
        try await create()
        try data.write(to: file(at: path), options: .atomic)
    }
    
    func read(from path: String) async throws -> Data? {
        guard hasData(at: path) else { return nil }
        return try? Data(contentsOf: file(at: path), options: .mappedIfSafe)
    }
    
    func remove(at path: String) async throws {
        try FileManager.default.removeItem(at: file(at: path))
    }
}
