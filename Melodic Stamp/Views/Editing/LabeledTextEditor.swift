//
//  LabeledTextEditor.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/12/18.
//

import SwiftUI
import Luminare
import SwiftUIIntrospect

struct LabeledTextEditor<Label>: View where Label: View {
    typealias Entries = MetadataBatchEditingEntries<String?>
    
    @Environment(\.luminareAnimationFast) private var animationFast
    
    private var entries: Entries
    @ViewBuilder private var label: () -> Label
    
    @State private var isEditorHovering: Bool = false
    @State private var isPresented: Bool = false
    
    init(
        entries: Entries,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.entries = entries
        self.label = label
    }
    
    init(
        _ key: LocalizedStringKey,
        entries: Entries
    ) where Label == Text {
        self.init(entries: entries) {
            Text(key)
        }
    }
    
    var body: some View {
        HStack {
            let isModified = entries.isModified
            let binding: Binding<String> = Binding {
                entries.projectedUnwrappedValue()?.wrappedValue ?? ""
            } set: { newValue in
                entries.setAll(newValue)
            }
            
            label()
            
            Spacer()
            
            if !isEmpty {
                Text("\(binding.wrappedValue.count) words")
                    .foregroundStyle(.placeholder)
            }
            
            AliveButton {
                isPresented.toggle()
            } label: {
                Image(systemSymbol: .textRedaction)
                    .foregroundStyle(.tint)
                    .tint(isModified ? .accent : .secondary)
            }
            .popover(isPresented: $isPresented, arrowEdge: .trailing) {
                ZStack(alignment: .topTrailing) {
                    LuminareTextEditor(text: binding)
                        .opacity(0.9)
                        .frame(width: 300, height: 450)
                        .luminareBordered(false)
                        .luminareHasBackground(false)
                    
                    if isEditorHovering {
                        HStack(spacing: 2) {
                            AliveButton {
                                entries.restoreAll()
                            } label: {
                                Image(systemSymbol: .arrowUturnLeft)
                            }
                            .disabled(!entries.isModified)
                            
                            AliveButton {
                                entries.setAll("")
                            } label: {
                                Image(systemSymbol: .trash)
                            }
                            .disabled(isEmpty)
                        }
                        .foregroundStyle(.red)
                        .bold()
                        .shadow(color: .red, radius: 12)
                        .padding(8)
                        .background {
                            Rectangle()
                                .fill(.ultraThinMaterial)
                        }
                        .clipShape(.capsule)
                        .padding(14)
                    }
                }
                .onHover { hover in
                    withAnimation(animationFast) {
                        isEditorHovering = hover
                    }
                }
            }
        }
        .modifier(LuminareHoverable())
        .luminareAspectRatio(contentMode: .fill)
    }
    
    private var isEmpty: Bool {
        if let value = entries.projectedUnwrappedValue()?.wrappedValue {
            value.isEmpty
        } else {
            true
        }
    }
}
