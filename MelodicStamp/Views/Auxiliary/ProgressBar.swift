//
//  ProgressBar.swift
//  Playground
//
//  Created by KrLite on 2024/11/17.
//

import SwiftUI

struct ProgressBar: View {
    @Environment(\.isEnabled) private var isEnabled
    
    @Namespace private var namespace
    
    @Binding var value: CGFloat
    var total: CGFloat = 1
    @Binding var isActive: Bool
    var shouldAnimate: Bool = false
    
    var shrinkFactor: CGFloat = 0.6
    var overshoot: CGFloat = 16
    var externalOvershootSign: FloatingPointSign?
    
    var onOvershootOffsetChange: (CGFloat, CGFloat) -> Void = { _, _ in }
    
    @State private var containerSize: CGSize = .zero
    @State private var overshootPercentage: CGFloat = .zero
    
    var body: some View {
        ZStack {
            Group {
                Capsule()
                    .foregroundStyle(.background)
                
                if isEnabled {
                    Capsule()
                        .mask(alignment: .leading) {
                            let percentage = max(0, min(1, self.percentage))
                            
                            Group {
                                if percentage < 1 {
                                    Color.white
                                        .frame(width: containerSize.width * percentage)
                                        .matchedGeometryEffect(id: "mask", in: namespace)
                                } else {
                                    Color.white
                                        .matchedGeometryEffect(id: "mask", in: namespace)
                                }
                            }
                            .animation(.instant, value: percentage < 1)
                        }
                }
            }
            .frame(height: isActive ? containerSize.height : containerSize.height * shrinkFactor)
            .animation(.smooth, value: isActive)
            .animation(.default.speed(5), value: value)
            .animation(shouldAnimate ? .default : nil, value: containerSize)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onGeometryChange(for: CGSize.self) { proxy in
            proxy.size
        } action: { size in
            containerSize = size
        }
        .gesture(DragGesture(minimumDistance: 0)
            .onChanged { gesture in
                guard isEnabled else { return }
                
                isActive = true
                update(percentage: gesture.location.x / containerSize.width)
                tryOvershoot(offset: gesture.location.x)
            }
            .onEnded { gesture in
                guard isEnabled else { return }
                
                isActive = false
                tryOvershoot(offset: 0)
            })
        
        .scaleEffect(.init(width: abs(overshootPercentage * overshootFactor) + 1, height: 1), anchor: .leading)
        .offset(x: overshootOffset)
        .animation(.default, value: overshootOffset)
        .animation(.default, value: isEnabled)
        
        .onChange(of: overshootOffset, onOvershootOffsetChange)
    }
    
    private var percentage: CGFloat {
        clamp(percentage: value / total)
    }
    
    private var overshootFactor: CGFloat {
        overshoot / containerSize.width
    }
    
    private var overshootOffset: CGFloat {
        if let externalOvershootSign {
            switch externalOvershootSign {
            case .plus:
                overshoot
            case .minus:
                -overshoot
            }
        } else {
            if overshootPercentage >= 0 {
                overshootPercentage * overshoot * 0.1
            } else {
                overshootPercentage * overshoot * 1.1
            }
        }
    }
    
    private func clamp(percentage: CGFloat) -> CGFloat {
        max(0, min(1, percentage))
    }
    
    private func update(percentage: CGFloat) {
        value = total * clamp(percentage: percentage)
    }
    
    private func tryOvershoot(offset: CGFloat) {
        if offset < 0 {
            overshootPercentage = max(tanh(offset * .pi), offset / overshoot)
        } else if offset > containerSize.width {
            let offset = offset - containerSize.width
            overshootPercentage = min(tanh(offset * .pi), offset / overshoot)
        } else {
            overshootPercentage = 0
        }
    }
}

#Preview {
    @Previewable @State var value: CGFloat = 0.42
    @Previewable @State var isActive: Bool = false
    
    ProgressBar(value: $value, isActive: $isActive)
        .frame(width: 300, height: 12)
        .padding()
        .backgroundStyle(.quinary)
}
