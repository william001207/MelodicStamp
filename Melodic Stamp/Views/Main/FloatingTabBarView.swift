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

    @Binding var selectedTabs: Set<SidebarTab>

    @State private var composables: Set<SidebarComposable> = []

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
        .onAppear {
            var composables: Set<SidebarComposable> = []
            for tab in selectedTabs {
                if isComposingAvailable(for: tab.composable, in: composables) {
                    composables.insert(tab.composable)
                } else {
                    selectedTabs.remove(tab)
                }
            }
            self.composables = composables
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
        let isSelected = selectedTabs.contains(tab)

        AliveButton {
            if isComposingAvailable(for: tab.composable, in: composables) {
                if isSelected {
                    selectedTabs.remove(tab)
                    let hasRemaining = !selectedTabs
                        .filter { $0.composable == tab.composable }
                        .isEmpty
                    if !hasRemaining {
                        composables.remove(tab.composable)
                    }
                } else {
                    selectedTabs.insert(tab)
                    composables.insert(tab.composable)
                }
            } else {
                tab.opposites.forEach { selectedTabs.remove($0) }
                tab.composable.opposites.forEach { composables.remove($0) }

                selectedTabs.insert(tab)
                composables.insert(tab.composable)
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

    private func isComposingAvailable(for composable: SidebarComposable, in composables: Set<SidebarComposable>) -> Bool {
        !composables.flatMap(\.opposites).contains(composable)
    }
}

//#Preview {
//    @Previewable @State var selectedTabs: Set<SidebarTab> = [.inspector]
//
//    FloatingTabBarView(floatingWindows: .init(), sections: [.init(tabs: SidebarTab.allCases)], selectedTabs: $selectedTabs)
//}
