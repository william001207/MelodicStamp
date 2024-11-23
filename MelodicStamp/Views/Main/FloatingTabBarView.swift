//
//  FloatingTabBarView.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/22.
//

import SwiftUI

struct FloatingTabBarView: View {
    @Bindable var floatingWindows: FloatingWindowsModel
    
    @State private var isHovering: Bool = true
    @State private var hoveringTabs: Set<SidebarTab> = .init()
    
    var sections: [SidebarSection]
    
    @Binding var selectedTabs: Set<SidebarTab>
    
    @State private var isComposed: Bool?
    
    var body: some View {
        ZStack {
            VisualEffectView(material: .popover, blendingMode: .behindWindow)
            
            VStack {
                ForEach(sections) { section in
                    VStack(alignment:.center, spacing: 4) {
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
                                HStack(alignment: .center) {
                                    tab.icon
                                        .font(.system(size: 18))
                                        .bold()
                                        .frame(width: 32, height: 32)
                                    if isHovering {
                                        Text(tab.title)
                                            .font(.headline)
                                            .fixedSize()
                                            .padding(.trailing)
                                    }
                                }
                                .frame(height: 32)
                                .padding(4)
                                .frame(maxWidth: .infinity, alignment: isHovering ? .leading : .center)
                                .opacity(isSelected || isTabHovering ? 1 : 0.75)
                                .background {
                                    if isSelected {
                                        if isHovering {
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(.tint)
                                                .fill(.tint.quaternary)
                                        } else {
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(.quaternary)
                                                .fill(.quaternary)
                                        }
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
                    .padding(4)
                }
            }
        }
        .onAppear {
            // avoid glitches on first hover
            isHovering = false
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
            withAnimation(.default.speed(2)) {
                isHovering = hover
            }
        })
        .background(.clear)
        .frame(width: isHovering ? nil : 48)
        .clipShape(.rect(cornerRadius: 24))
        
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(.rect(cornerRadius: 24))
    }
}

#Preview {
    @Previewable @State var selectedTabs: Set<SidebarTab> = .init([.playlist])
    
    FloatingTabBarView(floatingWindows: .init(), sections: [.init(items: SidebarTab.allCases)], selectedTabs: $selectedTabs)
}
