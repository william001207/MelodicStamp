//
//  FloatingTabBarView.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/22.
//

import SwiftUI

struct FloatingTabBarView: View {
    @Bindable var floatingWindows: FloatingWindowsModel
    
    @State private var isHovering: Bool = false
    @State private var hoveringTabs: Set<SidebarTab> = .init()
    
    var sections: [SidebarSection]
    
    @Binding var selectedTabs: Set<SidebarTab>
    
    @State private var isComposed: Bool?
    
    var body: some View {
        ZStack {
            VisualEffectView(material: .popover, blendingMode: .behindWindow)
            
            VStack {
                ForEach(sections) { section in
                    VStack(alignment:.center, spacing: 2.5) {
                        if let title = section.title {
                            Text(title)
                                .font(.caption)
                                .bold()
                                .foregroundStyle(.secondary)
                        }
                        
                        ForEach(section.items) { tab in
                            let isTabHovering = hoveringTabs.contains(tab)
                            let isSelected = selectedTabs.contains(tab)
                            
                            AliveButton {
                                if let isComposed {
                                    if tab.isComposable && isComposed {
                                        if isSelected {
                                            selectedTabs.remove(tab)
                                        } else {
                                            selectedTabs.insert(tab)
                                        }
                                    } else {
                                        selectedTabs = .init([tab])
                                    }
                                } else {
                                    isComposed = tab.isComposable
                                    selectedTabs = .init([tab])
                                }
                            } label: {
                                HStack(spacing: 10) {
                                    tab.icon
                                        .font(.system(size: 18))
                                        .bold()
                                        .frame(width: 35, height: 35)
                                    if isHovering {
                                        Text(tab.title)
                                            .font(.headline)
                                    }
                                }
                                .frame(height: 35)
                                .padding(5)
                                .frame(maxWidth: .infinity, alignment: isHovering ? .leading : .center)
                                .opacity(isSelected || isTabHovering ? 1 : 0.75)
                                .background {
                                    if isSelected {
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(.quaternary)
                                            .fill(.quaternary)
                                    } else if isTabHovering {
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(.quinary)
                                            .fill(.quinary)
                                    }
                                }
                                .onHover { hover in
                                    withAnimation(.default.speed(2)) {
                                        if hover {
                                            hoveringTabs.insert(tab)
                                        } else {
                                            hoveringTabs.remove(tab)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(5)
                }
            }
        }
        .onAppear {
            var isComposed: Bool?
            for tab in selectedTabs {
                if let isComposed {
                    if tab.isComposable != isComposed {
                        selectedTabs.remove(tab)
                    }
                } else {
                    isComposed = tab.isComposable
                }
            }
            self.isComposed = isComposed
        }
        .onHover(perform: { hover in
            withAnimation(.smooth.speed(2)) {
                isHovering = hover
            }
        })
        .background(.clear)
        .frame(width: isHovering ? 140 : 55)
        .clipShape(.rect(cornerRadius: 25))
        
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(width: 150, alignment: .leading)
        .contentShape(.rect(cornerRadius: 25))
    }
}

#Preview {
    @Previewable @State var selectedTabs: Set<SidebarTab> = .init([.playlist])
    
    FloatingTabBarView(floatingWindows: .init(), sections: [.init(items: SidebarTab.allCases)], selectedTabs: $selectedTabs)
}
