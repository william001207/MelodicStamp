//
//  Lyricline.swift
//  Melodic Stamp
//
//  Created by Xinshao_Air on 2024/12/1.
//

import Foundation

struct Lyricline: Equatable {
    enum LyricType: Equatable {
        case first, second, both
    }
    
    var stringF: String?
    var stringS: String?
    let time: LyricTime
    var type: LyricType
    var highlighted = false
}

class Lyric: NSObject {
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
    var lyrics = [(LyricTime, String)]()
    
    convenience init(_ lyricStr: String) {
        self.init()
        lyricStr.split(separator: "\n").map(String.init).forEach {
            var heads = [String]()
            var line = $0
            while line.starts(with: "["), line.contains("]") {
                let head = line.subString(from:"[", to: "]")
                heads.append(head)
                line = line.subString(from: "]")
            }
            
            if heads.count == 1, let h = heads.first {
                if let time = LyricTime(h) {
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
                if let time = heads.compactMap({ LyricTime($0) }).first {
                    lyrics.append((time, line))
                    if isTranslation {
                        lyrics.append((time, line))
                    }
                }
            }
        }
    }
}

struct LyricTime: Hashable {
    var minute: Int
    var second: Int
    var millisecond: Int
    var totalMS: Int
    
    var timeInterval: TimeInterval {
        return TimeInterval(totalMS) / 1000.0
    }
    
    init?(_ str: String) {
        let minS = str.split(separator: ":").map(String.init)
        guard minS.count == 2, let min = Int(minS.first ?? "") else { return nil }
        minute = min
        let sm = minS.last?.split(separator: ".").map(String.init)
        guard sm?.count == 2,
              let s = Int(sm?.first ?? ""),
              let ms = Int(sm?.last ?? "") else { return nil }
        second = s
        millisecond = ms
        totalMS = ((minute * 60) + second) * 1000 + millisecond
    }
}
