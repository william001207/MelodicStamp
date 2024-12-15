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
        let matches = regex.matches(in: self, range: NSRange(startIndex..., in: self))

        guard let match = matches.first,
              match.numberOfRanges == 4,
              let minutesRange = Range(match.range(at: 1), in: self),
              let secondsRange = Range(match.range(at: 2), in: self),
              let millisecondsRange = Range(match.range(at: 3), in: self),
              let minutes = Double(self[minutesRange]),
              let seconds = Double(self[secondsRange]),
              let milliseconds = Double(self[millisecondsRange])
        else {
            return TimeInterval(0)
        }

        let totalMilliseconds = (minutes * 60 + seconds) * 1000 + milliseconds
        let timeInterval = totalMilliseconds / 1000

        return timeInterval
    }
}

extension String {
    func normalizeSpaces() -> String {
        replacing(/\\u{(00A0|20[0-9A])}/, with: "")
    }
    
    func countConsecutiveSpacesBetweenNumbers(terminator: Character) -> [Int: Int] {
        var result: [Int: Int] = [:]
        var currentNumber: Int? = nil
        var spaceCount = 0
        var buffer = ""
        
        for character in self {
            if character.isWholeNumber {
                // Builds multi-digit numbers
                buffer.append(character)
            } else if character == terminator {
                // Handles the end of a number
                if let number = Int(buffer) {
                    if let previousNumber = currentNumber {
                        // Store the previous number and its space count
                        result[previousNumber] = spaceCount
                    }
                    // Updates current number
                    currentNumber = number
                    spaceCount = 0
                }
                buffer = ""
            } else if character.isWhitespace {
                // Counts consecutive spaces
                spaceCount += 1
            }
        }
        
        // Adds the last number to the result (if it exists)
        if let number = Int(buffer), let previousNumber = currentNumber {
            result[previousNumber] = spaceCount
            result[number] = 0
        }
        
        return result
    }
}

public extension String.Encoding {
    static let gbk: String.Encoding = {
        let gbkEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
        return String.Encoding(rawValue: gbkEncoding)
    }()
}
