//
//  FloatingTabBarView.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/22.
//

import SwiftUI

struct FloatingTabBarView: View {
    @EnvironmentObject private var model: FloatingWindowsModel
    
    @State private var hoveringStates: [SidebarItem: Bool] = [:]
    @State private var onHover: Bool = false
    
    let sections: [SidebarSection]
    
    @Binding var selectedItem: SidebarItem
    
    var body: some View {
        ZStack {
            VisualEffectView(material: .popover, blendingMode: .behindWindow)
            ForEach(self.sections) { section in
                VStack(alignment:.center, spacing: 2.5) {
                    ForEach(section.items) { item in
                        
                        let isHovering = hoveringStates[item] ?? false
                        let isSelected = self.selectedItem == item
                        
                        AliveButton {
                            self.selectedItem = item
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: item.iconName)
                                    .font(.system(size: 18.0).bold())
                                    .frame(width: 35, height: 35)
                                if onHover {
                                    Text(item.title)
                                        .font(.headline)
                                }
                            }
                            .frame(height: 35)
                            .padding(5)
                            .frame(maxWidth: .infinity, alignment: onHover ? .leading : .center)
                            .opacity(isSelected || isHovering ? 1 : 0.75)
                            .background {
                                if isSelected {
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(.quaternary, lineWidth: 2)
                                        .fill(.quaternary)
                                } else if isHovering {
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(.quinary, lineWidth: 2)
                                        .fill(.quinary)
                                }
                            }
                            .onHover { hover in
                                withAnimation(.default.speed(2)) {
                                    hoveringStates[item] = hover
                                }
                            }
                        }
                    }
                }
                .padding(5)
            }
        }
        .onHover(perform: { isOnHover in
            withAnimation(.smooth(duration: 0.32)) {
                onHover = isOnHover
            }
        })
        .background(.clear)
        .frame(width: onHover ? 140 : 55, height: 200)
        .clipShape(.rect(cornerRadius: 25))
        
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(width: 150, alignment: .leading)
        .contentShape(.rect(cornerRadius: 25))
    }
}

#Preview {
    @Previewable @State var selectedItem: SidebarItem = .home
    FloatingTabBarView(sections: sidebarSections, selectedItem: $selectedItem)
        .environmentObject(FloatingWindowsModel())
}
