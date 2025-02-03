//
//  UUIDShortenerTests.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/2/3.
//

import Foundation
@testable import MelodicStamp
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
