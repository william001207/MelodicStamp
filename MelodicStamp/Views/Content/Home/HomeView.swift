//
//  HomeView.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/22.
//

import AppKit
import SwiftUI
import Luminare
import SFSafeSymbols

struct HomeView: View {
    
    @State var model: PlayerModel = .shared
    @State var selectedItems: Set<PlaylistItem> = []
    @State var lastSelectedItem: PlaylistItem? = nil
    
    @State private var searchText: String = ""
    @State private var showEditMetadata: Bool = false
    @State private var showBatchEdit: Bool = false
    
    var body: some View {
        HStack(spacing: 20) {
            
            siderBar()
            
            VStack(alignment: .leading, spacing: 20) {
                homeTitle()
                
                playList()
            }
            .padding(.top, 20)
            .frame(maxWidth: .infinity)
            
            eidtView()
                .padding([.trailing, .vertical], 20)
                .padding(.bottom, 50)
                .padding(.top, 35)
            
        }
        .frame(minWidth: 1000, minHeight: 600)
    }
    
    // MARK: - ViewBuilder
    
    @ViewBuilder
    private func siderBar() -> some View {
        ZStack {
            VisualEffectView(material: .popover, blendingMode: .behindWindow)
            VStack(alignment: .trailing, spacing: 10) {
                VStack {
                    LuminareSection {
                        
                        LuminareTextField("Search", text: $searchText)
                        
                        HStack(spacing: 2) {
                            Button("Open File") {
                                openFile()
                            }
                            .buttonStyle(LuminareButtonStyle())
                            .keyboardShortcut("O", modifiers: [.command])
                            
                            Button("Add Files") {
                                addFiles()
                            }
                            .buttonStyle(LuminareButtonStyle())
                            .keyboardShortcut("A", modifiers: [.command])
                            
                        }
                        .frame(height: 45)
                    }
                    
                    Spacer()
                    
                    LuminareSection {
                        Button("Edit Metadata") {
                            withAnimation {
                                if selectedItems.count == 1 {
                                    showEditMetadata.toggle()
                                } else if selectedItems.count > 1 {
                                    showBatchEdit.toggle()
                                }
                            }
                        }
                        .disabled(selectedItems.isEmpty)
                        .buttonStyle(LuminareButtonStyle())
                    }
                    .frame(height: 45)
                }
                .padding(.horizontal, 10)
                .padding(.top, 50)
                .padding(.bottom, 10)
            }
        }
        .frame(width: 250)
        .background {
            RoundedRectangle(cornerRadius: 0.0)
                .fill(.quaternary)
                .frame(width: 250)
        }
    }
    
    @ViewBuilder
    private func homeTitle() -> some View {
        HStack {
            VStack {
                Text("Title")
                    .font(.title.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("subHeading")
                    .font(.title3.bold())
                    .foregroundStyle(Color.blue)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Folder Place")
                    .font(.subheadline.bold())
                    .foregroundStyle(Color.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Spacer()
            
            HStack(spacing: 10) {
                AliveButton {
                    
                } label: {
                    Image(systemSymbol: .playFill)
                        .font(.headline)
                        .foregroundStyle(Color.white)
                        .background {
                            Circle()
                                .foregroundStyle(Color.blue)
                                .frame(width: 40, height: 40)
                        }
                }
                .frame(width: 40, height: 40)
                
                AliveButton {
                    
                } label: {
                    Image(systemSymbol: .shuffle)
                        .font(.headline)
                        .foregroundStyle(Color.white)
                        .background {
                            Circle()
                                .foregroundStyle(Color.blue.opacity(0.25))
                                .frame(width: 40, height: 40)
                        }
                }
                .frame(width: 40, height: 40)
            }
        }
    }
    
    @ViewBuilder
    private func playList() -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 10) {
                ForEach(model.playlist()) { item in
                    AliveButton {
                        let hasShift = NSEvent.modifierFlags.contains(.shift)
                        let hasCommand = NSEvent.modifierFlags.contains(.command)
                        handleSelection(of: item, isShiftPressed: hasShift, isCommandPressed: hasCommand)
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.metadata.title ?? item.url.lastPathComponent)
                                    .font(.headline.bold())
                                Text(item.metadata.artist ?? "Unknown Artist")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(item.url.lastPathComponent)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            AliveButton {
                                model.play(item)
                            } label: {
                                Image(systemSymbol: .playCircle)
                                    .font(.system(size: 18.0).bold())
                                    .frame(width: 35, height: 35)
                            }
                        }
                        .padding(10)
                        .contentShape(Rectangle())
                        .background {
                            Group {
                                if selectedItems.contains(item) {
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.blue.opacity(0.2))
                                        .stroke(Color.blue, lineWidth: 2)
                                } else {
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(.quinary)
                                        .stroke(.quinary, lineWidth: 1)
                                }
                            }
                            .animation(.smooth(duration: 0.25), value: selectedItems.contains(item))
                        }
                    }
                    .frame(height: 65)
                }
            }
        }
    }
    
    @ViewBuilder
    private func eidtView() -> some View {
        ScrollView {
            LazyVStack {
                if let singleSelectedItem = selectedItems.first, showEditMetadata {
                    EditMetadataView(model: model, selectedItem: .constant(singleSelectedItem))
                } else if showBatchEdit {
                    BatchEditMetadataView(
                        model: model,
                        selectedItems: Array(selectedItems)
                    )
                }
            }
            .frame(maxWidth: 200)
        }
    }
    
    
    // MARK: - Action
    
    private func handleSelection(of item: PlaylistItem, isShiftPressed: Bool, isCommandPressed: Bool) {
        if isShiftPressed, let last = lastSelectedItem {
            if let startIndex = model.playlist().firstIndex(of: last),
               let endIndex = model.playlist().firstIndex(of: item) {
                let range = min(startIndex, endIndex)...max(startIndex, endIndex)
                let itemsInRange = model.playlist()[range]
                selectedItems.formUnion(itemsInRange)
            }
        } else if isCommandPressed {
            if selectedItems.contains(item) {
                selectedItems.remove(item)
            } else {
                selectedItems.insert(item)
            }
        } else {
            selectedItems = [item]
        }
        lastSelectedItem = item
    }
    
    func openFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedFileTypes = supportedPathExtensions
        
        if panel.runModal() == .OK, let url = panel.url {
            model.play(url)
        }
    }
    
    func addFiles() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.allowedFileTypes = supportedPathExtensions
        
        if panel.runModal() == .OK {
            model.addToPlaylist(urls: panel.urls)
        }
    }
}

#Preview {
    HomeView()
}
