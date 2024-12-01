//
//  Lyrics.swift
//  Melodic Stamp
//
//  Created by Xinshao_Air on 2024/12/1.
//

import Foundation

struct Lyricline: Equatable {
    enum LyricType: Equatable {
        case first
        case second
        case both
    }
    
    var stringF: String?
    var stringS: String?
    let time: TimeInterval
    var type: LyricType
    var highlighted = false
}

class Lyrics: NSObject {
    enum LyricTag: String {
        case artist = "ar"
        case album = "al"
        case title = "ti"
        case author = "au"
        case length
        case creater = "by"
        case offset
        case editor = "re"
        case version = "ve"
    }
    
    var tags = [LyricTag: String]()
    var lyrics = [(TimeInterval, String)]()
    
    convenience init(_ string: String) throws {
        self.init()
        
        try string.split(separator: "\n").map(String.init).forEach {
            var heads = [String]()
            var line = $0
            while line.starts(with: "["), line.contains("]") {
                let head = line.subString(from:"[", to: "]")
                heads.append(head)
                line = line.subString(from: "]")
            }
            
            if heads.count == 1, let h = heads.first {
                if let time = try TimeInterval(lyricTimeStamp: h) {
                    lyrics.append((time, line))
                } else {
                    let kv = h.split(separator: ":").map(String.init)
                    guard kv.count == 2 else { return }
                    if let str = kv.first,
                        let tag = LyricTag(rawValue: str) {
                        tags[tag] = kv.last
                    }
                }
            } else {
                let isTranslation = heads.contains { $0.starts(with: "tr:") }
                if let time = try heads.compactMap({ try TimeInterval(lyricTimeStamp: $0) }).first {
                    lyrics.append((time, line))
                    if isTranslation {
                        lyrics.append((time, line))
                    }
                }
            }
        }
    }
}
