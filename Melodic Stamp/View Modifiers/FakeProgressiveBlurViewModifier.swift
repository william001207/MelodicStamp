//
//  FakeProgressiveBlurViewModifier.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/24.
//

import SwiftUI

struct FakeProgressiveBlurViewModifier: ViewModifier {
    var material: NSVisualEffectView.Material = .hudWindow
    var startPoint: UnitPoint, endPoint: UnitPoint
    
    @State private var opacity: CGFloat = .zero
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .overlay {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .mask {
                            LinearGradient(
                                colors: [Color.black.opacity(0),  // sin(x * pi / 2)
                                         Color.black.opacity(0.383),
                                         Color.black.opacity(0.707),
                                         Color.black.opacity(0.924),
                                         Color.black],
                                startPoint: startPoint,
                                endPoint: endPoint
                            )
                        }
                        .opacity(opacity)
                        .allowsHitTesting(false)
                        .onAppear {
                            DispatchQueue.main.async {
                                withAnimation {
                                    opacity = 1
                                }
                            }
                        }
                }
        }
    }
}
