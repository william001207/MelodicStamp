//
//  EnvironmentValues.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/23.
//

import SwiftUI

extension EnvironmentValues {
    @Entry var namespace: Namespace.ID!
    @Entry var appDelegate: AppDelegate!
    @Entry var availableTypeSizes: ClosedRange<DynamicTypeSize> = .small...(.xxLarge)
}
