//
//  ContentView.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/19.
//

import SwiftUI
import AppKit
import CAAudioHardware
import CSFBAudioEngine

struct ContentView: View {
    @EnvironmentObject var playerViewModel: PlayerViewModel
    @State private var showOpenPanel: Bool = false
    @State private var showAddFilesPanel: Bool = false
    @State private var showAnalyzeFilesPanel: Bool = false
    @State private var showExportPanel: Bool = false
    @State private var exportURL: URL?
    @State private var showEditMetadata: Bool = false
    @State private var selectedItem: PlaylistItem?
    
    static var supportedPathExtensions: [String] = {
        var pathExtensions = [String]()
        pathExtensions.append(contentsOf: AudioDecoder.supportedPathExtensions)
        pathExtensions.append(contentsOf: DSDDecoder.supportedPathExtensions)
        return pathExtensions
    }()
    
    var body: some View {
        VStack {
            // 播放控制
            HStack {
                Button(action: playPause) {
                    Image(systemName: playerViewModel.player.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                .disabled(playerViewModel.playlist.isEmpty)
                
                Button(action: playerViewModel.seekBackward) {
                    Image(systemName: "backward.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
                .disabled(!playerViewModel.player.supportsSeeking)
                
                Button(action: playerViewModel.seekForward) {
                    Image(systemName: "forward.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
                .disabled(!playerViewModel.player.supportsSeeking)
                
                Spacer()
                
                // 设备选择
                Picker("Output Device", selection: Binding(
                    get: { playerViewModel.selectedDevice },
                    set: { newDevice in
                        if let device = newDevice {
                            playerViewModel.setOutputDevice(device)
                        }
                    }
                )) {
                    ForEach(playerViewModel.outputDevices, id: \.objectID) { device in
                        Text(try! device.name).tag(device as AudioDevice?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(maxWidth: 500)
            }
            .padding()
            
            // 进度条
            VStack {
                Slider(value: Binding(
                    get: { playerViewModel.progress },
                    set: { newValue in
                        playerViewModel.seek(position: newValue)
                    }
                ), in: 0...1)
                .padding([.leading, .trailing])
                
                HStack {
                    Text(formatTime(playerViewModel.elapsed))
                    Spacer()
                    Text(formatTime(playerViewModel.remaining))
                }
                .padding([.leading, .trailing])
            }
            
            // 播放列表
            List(selection: $selectedItem) {
                ForEach(playerViewModel.playlist) { item in
                    HStack {
                        if let picture = item.metadata.attachedPictures.first?.image {
                            Image(nsImage: picture)
                                .resizable()
                                .frame(width: 40, height: 40)
                                .cornerRadius(5)
                        } else {
                            Image(systemName: "photo")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.gray)
                        }
                        
                        VStack(alignment: .leading) {
                            Text(item.metadata.title ?? "Unknown Title")
                                .font(.headline)
                            Text(item.metadata.artist ?? "Unknown Artist")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        
                        Button("Play") {
                            playerViewModel.play(item: item)
                        }
                    }
                    .contentShape(Rectangle())
                    .background {
                        if selectedItem == item {
                            Color.blue
                        } else {
                            Color.clear
                        }
                    }
                    .onTapGesture {
                        selectedItem = item
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .frame(maxHeight: .infinity)
            
            // 控制按钮
            HStack {
                Button("打开文件") {
                    openFile()
                }
                .keyboardShortcut("O", modifiers: [.command])
                
                Button("添加文件") {
                    addFiles()
                }
                .keyboardShortcut("A", modifiers: [.command])
                
                Button("分析文件") {
                    analyzeFiles()
                }
                .keyboardShortcut("E", modifiers: [.command])
                
                Button("导出WAVE文件") {
                    exportWAVEFile()
                }
                .keyboardShortcut("W", modifiers: [.command])
                
                Button("编辑元信息") {
                    if let item = selectedItem {
                        self.selectedItem = item
                        self.showEditMetadata = true
                    }
                }
                .disabled(selectedItem == nil)
                .keyboardShortcut("M", modifiers: [.command])
                
                Spacer()
            }
            .padding()
        }
        .frame(minWidth: 800, minHeight: 600)
        .alert(isPresented: $playerViewModel.showError) {
            Alert(title: Text("错误"), message: Text(playerViewModel.errorMessage ?? "未知错误"), dismissButton: .default(Text("确定")))
        }
        .sheet(isPresented: $showEditMetadata) {
            if let item = selectedItem {
                EditMetadataView(viewModel: playerViewModel, selectedItem: $selectedItem)
            }
        }
    }
    
    // MARK: - Actions
    
    func playPause() {
        do {
            try playerViewModel.togglePlayPause()
        } catch {
            playerViewModel.handleError(error)
        }
    }
    
    func deleteItems(at offsets: IndexSet) {
        let urlsToRemove = offsets.map { playerViewModel.playlist[$0].url }
        playerViewModel.removeFromPlaylist(urls: urlsToRemove)
        playerViewModel.savePlaylist()
    }
    
    func openFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedFileTypes = ContentView.supportedPathExtensions
        
        if panel.runModal() == .OK, let url = panel.url {
            playerViewModel.play(url)
        }
    }
    
    func addFiles() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.allowedFileTypes = ContentView.supportedPathExtensions
        
        if panel.runModal() == .OK {
            playerViewModel.addToPlaylist(urls: panel.urls)
        }
    }
    
    func analyzeFiles() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.allowedFileTypes = ContentView.supportedPathExtensions
        
        if panel.runModal() == .OK {
            playerViewModel.analyzeFiles(urls: panel.urls)
        }
    }
    
    func exportWAVEFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedFileTypes = ContentView.supportedPathExtensions
        
        if panel.runModal() == .OK, let url = panel.url {
            let destURL = url.deletingPathExtension().appendingPathExtension("wav")
            if FileManager.default.fileExists(atPath: destURL.path) {
                let alert = NSAlert()
                alert.messageText = "是否覆盖现有文件？"
                alert.informativeText = "同名文件已存在。"
                alert.addButton(withTitle: "覆盖")
                alert.addButton(withTitle: "取消")
                
                if alert.runModal() != .alertFirstButtonReturn {
                    return
                }
            }
            
            playerViewModel.exportWAVEFile(url: url)
        }
    }
    
    // MARK: - Helper
    
    func formatTime(_ time: Double) -> String {
        let totalSeconds = Int(abs(time))
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

