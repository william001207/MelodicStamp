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
    
    @State private var showEditMetadata: Bool = false
    @State private var showBatchEdit: Bool = false
    
    var body: some View {
        HStack(alignment: .top) {
            homeTitle()
                .padding([.leading, .vertical], 20)
                .padding(.bottom, 50)
                .padding(.top, 35)
            
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
                                            .fill( Color.blue.opacity(0.2))
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
                    }
                }
                .padding([.horizontal, .vertical], 20)
                .padding(.bottom, 50)
                .padding(.top, 35)
            }
            .frame(maxWidth: .infinity)
            
            eidtView()
                .padding([.trailing, .vertical], 20)
                .padding(.bottom, 50)
                .padding(.top, 35)
            
        }
        .toolbar {
            ToolbarItemGroup(placement: .automatic){
                Button("Open File") {
                    openFile()
                }
                .keyboardShortcut("O", modifiers: [.command])
                
                Button("Add Files") {
                    addFiles()
                }
                .keyboardShortcut("A", modifiers: [.command])
                
                Button("Edit Metadata") {
                    if selectedItems.count == 1 {
                        showEditMetadata.toggle()
                    } else if selectedItems.count > 1 {
                        showBatchEdit.toggle()
                    }
                }
                .disabled(selectedItems.isEmpty)
            }
        }
    }
    
    @ViewBuilder
    private func homeTitle() -> some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 12.5)
                    .fill(Color.gray)
                    .shadow(radius: 10)
                Image(systemSymbol: .photo)
                    .font(.system(size: 100.0).bold())
            }
            .frame(width: 200, height: 200)
            
            Text("PlayList")
                .font(.title.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Founder")
                .font(.title3.bold())
                .foregroundStyle(Color.blue)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Place")
                .font(.subheadline.bold())
                .foregroundStyle(Color.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 10) {
                AliveButton {
                    
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12.5)
                            .foregroundStyle(Color.blue)
                            .frame(width: 95, height: 40)
                        HStack {
                            Group {
                                Image(systemSymbol: .playFill)
                                Text("Play")
                            }
                            .font(.headline)
                            .foregroundStyle(Color.white)
                        }
                    }
                }
                
                AliveButton {
                    
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12.5)
                            .foregroundStyle(Color.blue.opacity(0.25))
                            .frame(width: 95, height: 40)
                        HStack {
                            Group {
                                Image(systemSymbol: .shuffle)
                                Text("Shuffle")
                            }
                            .font(.headline)
                            .foregroundStyle(Color.blue)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: 200)
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
        panel.allowedFileTypes = ContentView.supportedPathExtensions
        
        if panel.runModal() == .OK, let url = panel.url {
            model.play(url)
        }
    }
    
    func addFiles() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.allowedFileTypes = ContentView.supportedPathExtensions
        
        if panel.runModal() == .OK {
            model.addToPlaylist(urls: panel.urls)
        }
    }
}

#Preview {
    HomeView()
}
