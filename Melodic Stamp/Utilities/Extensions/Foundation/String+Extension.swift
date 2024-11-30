//
//  String+Extension.swift
//  Melodic Stamp
//
//  Created by Xinshao_Air on 2024/12/1.
//

import Foundation

extension String {
    func subString(from startString: String, to endString: String) -> String {
        var str = self
        if let startIndex = self.range(of: startString)?.upperBound {
            str.removeSubrange(str.startIndex ..< startIndex)
            if let endIndex = str.range(of: endString)?.lowerBound {
                str.removeSubrange(endIndex ..< str.endIndex)
                return str
            }
        }
        return ""
    }
    
    func subString(from startString: String) -> String {
        var str = self
        if let startIndex = self.range(of: startString)?.upperBound {
            str.removeSubrange(self.startIndex ..< startIndex)
            return str
        }
        return ""
    }
    
    func subString(to endString: String) -> String {
        var str = self
        if let endIndex = self.range(of: endString)?.lowerBound {
            str.removeSubrange(endIndex ..< str.endIndex)
            return str
        }
        return ""
    }
}
