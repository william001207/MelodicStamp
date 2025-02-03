//
//  SequenceExtensionTests.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/2/3.
//

import Foundation
@testable import MelodicStamp
import Testing

@Suite struct SequenceExtensionTests {
    @Test func normalize() {
        let sequence: [Float] = [1, 2, 3, 4, 5]
        let normalizedSequence: [Float] = [0, 0.25, 0.5, 0.75, 1]
        #expect(sequence.normalized == normalizedSequence)
    }
}
