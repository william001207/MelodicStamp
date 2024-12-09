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
            Menu("Open Cache Directories…") {
                ForEach(CacheDirectory.allCases) { directory in
                    Button {
                        Task {
                            try await directory.create()
                            NSWorkspace.shared.open(directory.url)
                        }
                    } label: {
                        Text("Cache/\(directory.rawValue)")
                    }
                }
            }
            
            Menu("Remove Cache Directories…") {
                ForEach(CacheDirectory.allCases) { directory in
                    Button {
                        Task {
                            try await directory.remove()
                        }
                    } label: {
                        Text("Cache/\(directory.rawValue)")
                    }
                }
            }
        }
    }
}
