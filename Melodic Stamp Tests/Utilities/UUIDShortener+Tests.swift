//
//  UUIDShortener+Tests.swift
//  Melodic Stamp Tests
//
//  Created by KrLite on 2025/1/28.
//

import Foundation
@testable import Melodic_Stamp
import Testing

@Suite struct UUIDShortenerTests {
    @Test func shortenAndExpand() {
        let uuid = UUID()
        let shortened = UUIDShortener.shorten(uuid: uuid)
        let expanded = UUIDShortener.expand(shortened: shortened)!
        print(shortened, expanded)
        #expect(expanded == uuid)
    }
}
