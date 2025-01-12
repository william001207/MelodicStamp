//
//  FloatingTabBarView.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/22.
//

import Luminare
import SwiftUI

struct FloatingTabBarView: View {
    @Environment(FloatingWindowsModel.self) private var floatingWindows

    @Environment(\.luminareAnimation) private var animation
    @Environment(\.luminareAnimationFast) private var animationFast

    @Binding var isInspectorPresented: Bool
    @Binding var selectedContentTab: SidebarContentTab
    @Binding var selectedInspectorTab: SidebarInspectorTab

    @State private var isHovering: Bool = true // Crucial!
    @State private var isDragging: Bool = false
    @State private var hoveringTabs: Set<AnyHashable> = []

    var body: some View {
        ZStack {
            VisualEffectView(material: .popover, blendingMode: .behindWindow)

            VStack(alignment: .leading, spacing: 0) {
                Group {
                    ForEach(SidebarContentTab.allCases) { tab in
                        contentTab(for: tab)
                    }

                    sectionLabel("Inspector")

                    ForEach(selectedContentTab.inspectors) { tab in
                        inspectorTab(for: tab)
                    }
                }
                .padding(4)
                .transition(.blurReplace)
            }
            .animation(animation, value: selectedContentTab)
        }
        .onAppear {
            // Avoid glitches on first hover
            isHovering = false
        }
        .onHover { hover in
            withAnimation(animation) {
                isHovering = hover
            }
        }
        .onChange(of: selectedContentTab) { _, newValue in
            guard isInspectorPresented else { return }
            if !newValue.inspectors.contains(selectedInspectorTab) {
                // Tell the inspector to close
                isInspectorPresented = false
            }
        }
        .background(.clear)
        .frame(width: isExpanded ? nil : 48)
        .clipShape(.rect(cornerRadius: 24))
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(.rect(cornerRadius: 24))
        .fixedSize(horizontal: false, vertical: true) // Force resizing window
    }

    private var isExpanded: Bool {
        isHovering || isDragging
    }

    @ViewBuilder private func sectionLabel(_ key: LocalizedStringKey) -> some View {
        Group {
            if isExpanded {
                Text(key)
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

    @ViewBuilder private func contentTab(for tab: SidebarContentTab) -> some View {
        let isSelected = selectedContentTab == tab

        AliveButton {
            selectedContentTab = tab
        } label: {
            label(for: tab, isSelected: isSelected)
        } onGestureChanged: { _ in
            withAnimation(animation) {
                isDragging = true
            }
        } onGestureEnded: { _ in
            withAnimation(animation) {
                isDragging = false
            }
        }
        .onHover { hover in
            withAnimation(animationFast) {
                if hover {
                    hoveringTabs.removeAll()
                    hoveringTabs.insert(tab)
                } else {
                    hoveringTabs.remove(tab)
                }
            }
        }
    }

    @ViewBuilder private func inspectorTab(for tab: SidebarInspectorTab) -> some View {
        let isSelected = isInspectorPresented && selectedInspectorTab == tab

        AliveButton {
            if isSelected {
                isInspectorPresented.toggle()
            } else {
                isInspectorPresented = true
                selectedInspectorTab = tab
            }
        } label: {
            label(for: tab, isSelected: isSelected)
        } onGestureChanged: { _ in
            isDragging = true
        } onGestureEnded: { _ in
            isDragging = false
        }
        .onHover { hover in
            withAnimation(animationFast) {
                if hover {
                    hoveringTabs.insert(tab)
                } else {
                    hoveringTabs.remove(tab)
                }
            }
        }
    }

    @ViewBuilder private func label(for tab: some SidebarTab, isSelected: Bool) -> some View {
        let isTabHovering = hoveringTabs.contains(tab)

        HStack(alignment: .center) {
            Image(systemSymbol: tab.systemSymbol)
                .font(.system(size: 18))
                .frame(width: 32, height: 32)

            if isExpanded {
                Text(tab.title)
                    .font(.headline)
                    .fixedSize()
                    .padding(.trailing)
            }
        }
        .frame(height: 32)
        .padding(4)
        .frame(maxWidth: .infinity, alignment: isExpanded ? .leading : .center)
        .opacity(isSelected || isTabHovering ? 1 : 0.75)
        .background {
            if isSelected {
                if isExpanded {
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
