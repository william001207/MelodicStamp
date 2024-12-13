//
//  DebugToolbar.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/9.
//

import SwiftUI

struct DebugToolbar: View {
    var body: some View {
        Menu("Debug") {
            if let version = Bundle.main.appVersion {
                Text("\(Bundle.main.displayName) - \(version)")
            } else {
                Text("\(Bundle.main.displayName)")
            }
        }
    }
}
