//
//  AnimatedString.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/12/26.
//

import Foundation

protocol AnimatedString: Equatable, Hashable, Identifiable {
    var content: String { get }
    var beginTime: TimeInterval? { get }
    var endTime: TimeInterval? { get }
}

extension AnimatedString {
    var duration: Duration? {
        guard let beginTime, let endTime else { return nil }
        return Duration(endTime - beginTime)
    }
}

struct PlainAnimatedString: AnimatedString {
    var content: String
    var beginTime: TimeInterval?
    var endTime: TimeInterval?

    let id = UUID()

    init(_ content: String, beginTime: TimeInterval? = nil, endTime: TimeInterval? = nil) {
        self.content = content
        self.beginTime = beginTime
        self.endTime = endTime
    }
}
