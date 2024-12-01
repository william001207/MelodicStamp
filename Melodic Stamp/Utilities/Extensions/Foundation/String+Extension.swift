//
//  String+Extension.swift
//  Melodic Stamp
//
//  Created by Xinshao_Air on 2024/12/1.
//

import Foundation

extension String {
    func extractNearest(from startString: String? = nil, to endString: String? = nil) -> Substring {
        let startIndex = if let startString, let index = range(of: startString)?.lowerBound {
            index
        } else {
            self.startIndex
        }
        let endIndex = if let endString, let index = String(self[..<startIndex]).range(of: endString)?.upperBound {
            index
        } else {
            self.endIndex
        }
        return self[startIndex ..< endIndex]
    }
}

extension String {
    func toTimeInterval() -> TimeInterval {
        let pattern = #"(\d+):(\d+)\.(\d+)"#
        let regex = try! NSRegularExpression(pattern: pattern)
        let matches = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
        
        guard let match = matches.first,
              match.numberOfRanges == 4,
              let minutesRange = Range(match.range(at: 1), in: self),
              let secondsRange = Range(match.range(at: 2), in: self),
              let millisecondsRange = Range(match.range(at: 3), in: self),
              let minutes = Double(self[minutesRange]),
              let seconds = Double(self[secondsRange]),
              let milliseconds = Double(self[millisecondsRange]) else {
            return TimeInterval(0)
        }
        
        let totalMilliseconds = (minutes * 60 + seconds) * 1000 + milliseconds
        let timeInterval = totalMilliseconds / 1000
        
        return timeInterval
    }
}

extension String {
    func normalizeSpaces() -> String {
        return self.replacingOccurrences(of: "\u{00A0}", with: " ")
                   .replacingOccurrences(of: "\u{2000}", with: " ")
                   .replacingOccurrences(of: "\u{2001}", with: " ")
                   .replacingOccurrences(of: "\u{2002}", with: " ")
                   .replacingOccurrences(of: "\u{2003}", with: " ")
                   .replacingOccurrences(of: "\u{2004}", with: " ")
                   .replacingOccurrences(of: "\u{2005}", with: " ")
                   .replacingOccurrences(of: "\u{2006}", with: " ")
                   .replacingOccurrences(of: "\u{2007}", with: " ")
                   .replacingOccurrences(of: "\u{2008}", with: " ")
                   .replacingOccurrences(of: "\u{2009}", with: " ")
                   .replacingOccurrences(of: "\u{200A}", with: " ")
    }
}

extension String.Encoding {
    public static let gbk: String.Encoding = {
        let gbkEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
        return String.Encoding(rawValue: gbkEncoding)
    }()
}
