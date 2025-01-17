//
//  TemporaryStorage.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/17.
//

import Foundation

struct TemporaryStorage: Hashable, Codable {
    let urls: Set<URL>
    let shouldPlay: Bool

    init(urls: Set<URL> = [], shouldPlay: Bool = false) {
        let urls = urls.flatMap { url in
            FileHelper.flatten(contentsOfFolder: url, allowedContentTypes: .init(allowedContentTypes))
        }
        self.urls = Set(urls)
        self.shouldPlay = shouldPlay
    }
}
