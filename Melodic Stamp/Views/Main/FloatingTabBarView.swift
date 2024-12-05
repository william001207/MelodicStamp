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
    @State private var hoveringTabs: Set<SidebarTab> = []

    var sections: [SidebarSection]

    @Binding var isInspectorPresented: Bool
    @Binding var selectedTab: SidebarTab

    var body: some View {
        ZStack {
            VisualEffectView(material: .popover, blendingMode: .behindWindow)

            VStack(alignment: .leading, spacing: 0) {
                ForEach(sections) { section in
                    Group {
                        if let title = section.title {
                            Group {
                                if isHovering {
                                    Text(title)
                                        .font(.caption)
                                        .bold()
                                        .foregroundStyle(.secondary)
                                } else {
                                    Divider()
                                }
                            }
                            .frame(height: 8)
                            .padding(.horizontal, 8)
                            .transition(.blurReplace)
                        }

                        ForEach(section.tabs) { tab in
                            tabView(for: tab)
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
                    .padding(4)
                }
            }
        }
        .onAppear {
            // avoid glitches on first hover
            isHovering = false
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

    @ViewBuilder private func tabView(for tab: SidebarTab) -> some View {
        let isTabHovering = hoveringTabs.contains(tab)
        let isSelected = isInspectorPresented && tab == selectedTab

        AliveButton {
            if selectedTab == tab {
                isInspectorPresented.toggle()
            } else {
                isInspectorPresented = true
                selectedTab = tab
            }
        } label: {
            HStack(alignment: .center) {
                Image(systemSymbol: tab.systemSymbol)
                    .font(.system(size: 18))
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
        }
    }
}

// #Preview {
//    @Previewable @State var selectedTab: SidebarTab = .inspector
//
//    FloatingTabBarView(floatingWindows: .init(), sections: [.init(tabs: SidebarTab.allCases)], selectedTab: $selectedTab)
// }
