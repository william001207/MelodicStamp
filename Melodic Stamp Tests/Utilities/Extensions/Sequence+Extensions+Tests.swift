//
//  Sequence+Extensions+Tests.swift
//  Melodic Stamp Tests
//
//  Created by KrLite on 2025/1/21.
//

import Foundation
@testable import Melodic_Stamp
import Testing

@Suite struct SequenceExtensionTests {
    @Test func normalize() {
        let sequence: [Float] = [1, 2, 3, 4, 5]
        let normalizedSequence: [Float] = [0, 0.25, 0.5, 0.75, 1]
        #expect(sequence.normalized == normalizedSequence)
    }
}
