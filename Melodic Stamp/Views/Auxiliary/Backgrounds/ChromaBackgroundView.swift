//
//  ChromaBackgroundView.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/13.
//

import SwiftUI

struct ChromaBackgroundView: View {
    var hasDynamics: Bool = true

    var body: some View {
        AnimatedGrid(hasDynamics: hasDynamics)
    }
}

#if DEBUG
    #Preview(traits: .modifier(PreviewEnvironments())) {
        ChromaBackgroundView()
    }
#endif
