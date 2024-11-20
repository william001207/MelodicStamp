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
    @Environment(\.openWindow) var openWindow
    
    @State var model: PlayerModel
    
    @State private var showOpenPanel: Bool = false
    @State private var showAddFilesPanel: Bool = false
    @State private var showAnalyzeFilesPanel: Bool = false
    @State private var showExportPanel: Bool = false
    @State private var exportURL: URL?
    
    @State private var showEditMetadata: Bool = false
    @State private var showBatchEdit: Bool = false
    
    @State private var selectedItems: Set<PlaylistItem> = []
    
    static var supportedPathExtensions: [String] = {
        var pathExtensions = [String]()
        pathExtensions.append(contentsOf: AudioDecoder.supportedPathExtensions)
        pathExtensions.append(contentsOf: DSDDecoder.supportedPathExtensions)
        return pathExtensions
    }()
    
    var body: some View {
        VStack {
            Button("Open Mini Player") {
                openWindow(id: "mini-player")
            }
        }
        
//        VStack {
            // 播放控制
//            HStack {
//                if let picture = model.nowPlaying?.metadata.attachedPictures.first?.image {
//                    let resizedImage = resizeImage(image: picture, maxSize: 40)
//                    Image(nsImage: resizedImage)
//                        .resizable()
//                        .frame(width: 40, height: 40)
//                        .cornerRadius(5)
//                } else {
//                    Image(systemName: "photo")
//                        .resizable()
//                        .frame(width: 40, height: 40)
//                        .foregroundColor(.gray)
//                }
                
//                if let metadata = model.currentMetadata {
//                    VStack(alignment: .leading) {
//                        Text(nowPlaying.metadata.title ?? nowPlaying.url.lastPathComponent)
//                            .font(.headline)
//                        Text(nowPlaying.metadata.artist ?? "未知艺术家")
//                            .font(.subheadline)
//                            .foregroundColor(.secondary)
//                        Text(nowPlaying.url.lastPathComponent)
//                            .font(.caption)
//                            .foregroundColor(.secondary)
//                    }
//                    .padding([.leading, .trailing, .bottom])
//                } else {
//                    VStack(alignment: .center) {
//                        Text("暂无播放内容")
//                    }
//                }
                
//                Button(action: model.previousTrack) {
//                    Image(systemName: "backward.fill")
//                        .resizable()
//                        .frame(width: 30, height: 30)
//                }
//                .disabled(!model.canNavigatePrevious())
//                
//                Button(action: playPause) {
//                    Image(systemName: model.player.isPlaying ? "pause.circle.fill" : "play.circle.fill")
//                        .resizable()
//                        .frame(width: 40, height: 40)
//                }
//                .disabled(model.playlist.isEmpty)
//                
//                Button(action: model.nextTrack) {
//                    Image(systemName: "forward.fill")
//                        .resizable()
//                        .frame(width: 30, height: 30)
//                }
//                .disabled(!model.canNavigateNext())
//                
//                Button(action: model.seekBackward) {
//                    Image(systemName: "5.arrow.trianglehead.counterclockwise")
//                        .resizable()
//                        .frame(width: 30, height: 30)
//                }
//                .disabled(!model.player.supportsSeeking)
//                
//                Button(action: model.seekForward) {
//                    Image(systemName: "5.arrow.trianglehead.clockwise")
//                        .resizable()
//                        .frame(width: 30, height: 30)
//                }
//                .disabled(!model.player.supportsSeeking)
//                
//                Spacer()
//                
//                Picker("播放模式", selection: $model.playbackMode) {
//                    ForEach(PlaybackMode.allCases) { mode in
//                        Text(mode.rawValue).tag(mode)
//                    }
//                }
//                .pickerStyle(.menu)
//                .frame(maxWidth: 400)
//                
//                // 设备选择
//                Picker("Output Device", selection: Binding(
//                    get: { model.selectedDevice },
//                    set: { newDevice in
//                        if let device = newDevice {
//                            model.setOutputDevice(device)
//                        }
//                    }
//                )) {
//                    ForEach(model.outputDevices, id: \.objectID) { device in
//                        Text(try! device.name).tag(device as AudioDevice?)
//                    }
//                }
//                .pickerStyle(MenuPickerStyle())
//                .frame(maxWidth: 400)
//            }
//            .padding()
            
//            // 进度条
//            VStack {
//                Slider(value: Binding(
//                    get: { model.progress },
//                    set: { newValue in
//                        model.seek(position: newValue)
//                    }
//                ), in: 0...1)
//                .padding([.leading, .trailing])
//                
//                HStack {
//                    Text(formatTime(model.elapsed))
//                    Spacer()
//                    Text(formatTime(model.remaining))
//                }
//                .padding([.leading, .trailing])
//            }
            
            // 播放列表
//            List(selection: $selectedItems) {
//                ForEach(model.playlist) { item in
//                    HStack {
//                        /*
//                        if let picture = item.metadata.attachedPictures.first?.image {
//                            let resizedImage = resizeImage(image: picture, maxSize: 40)
//                            Image(nsImage: resizedImage)
//                                .resizable()
//                                .frame(width: 40, height: 40)
//                                .cornerRadius(5)
//                        } else {
//                            Image(systemName: "photo")
//                                .resizable()
//                                .frame(width: 40, height: 40)
//                                .foregroundColor(.gray)
//                        }
//                        */
//                        
//                        VStack(alignment: .leading) {
//                            Text(item.metadata.title ?? item.url.lastPathComponent)
//                                .font(.headline)
//                            Text(item.metadata.artist ?? "Unknown Artist")
//                                .font(.subheadline)
//                                .foregroundColor(.secondary)
//                            
//                            Text(item.url.lastPathComponent)
//                                .font(.caption)
//                                .foregroundColor(.secondary)
//                        }
//                        Spacer()
//                        
//                        Button("Play") {
//                            model.play(item: item)
//                        }
//                    }
//                    .contentShape(Rectangle())
//                    .background {
//                        if selectedItems.contains(item) {
//                            Color.blue.opacity(0.3) // Highlight color for selected items
//                        } else {
//                            Color.clear
//                        }
//                    }
//                    .onTapGesture {
//                        if selectedItems.contains(item) {
//                            selectedItems.remove(item)
//                        } else {
//                            selectedItems.insert(item)
//                        }
//                    }
//                }
//                .onDelete(perform: deleteItems)
//            }
//            .frame(maxHeight: .infinity)
            
            // 控制按钮
//            HStack {
//                Button("打开文件") {
//                    openFile()
//                }
//                .keyboardShortcut("O", modifiers: [.command])
//                
//                Button("添加文件") {
//                    addFiles()
//                }
//                .keyboardShortcut("A", modifiers: [.command])
//                
//                Button("分析文件") {
//                    analyzeFiles()
//                }
//                .keyboardShortcut("E", modifiers: [.command])
//                
//                Button("导出WAVE文件") {
//                    exportWAVEFile()
//                }
//                .keyboardShortcut("W", modifiers: [.command])
                
                // 单项或批量编辑按钮
//                Button("编辑元信息") {
//                    if selectedItems.count == 1 {
//                        // 单选编辑
//                        showEditMetadata = true
//                    } else if selectedItems.count > 1 {
//                        // 批量编辑
//                        showBatchEdit = true
//                    }
//                }
//                .disabled(selectedItems.isEmpty) // 禁用按钮条件：未选中任何项目
//                .keyboardShortcut("M", modifiers: [.command]) // 添加快捷键
//                
//                Spacer()
//                
//                HStack {
//                    Image(systemName: "speaker.3.fill")
//                    Slider(value: Binding(
//                        get: { Float(model.volume) },
//                        set: { newValue in
//                            model.volume = newValue
//                        }
//                    ), in: 0...1)
//                    .frame(width: 100)
//                }
//                
//                Button("打开MiniPlayBar") {
//                    openWindow(id: "SecondView")
//                }
//                
//            }
//            .padding()
//        }
//        .frame(minWidth: 800, minHeight: 600)
//        .alert(isPresented: $model.showError) {
//            Alert(title: Text("错误"), message: Text(model.errorMessage ?? "未知错误"), dismissButton: .default(Text("确定")))
//        }
//        // 单项编辑弹窗
//        .sheet(isPresented: $showEditMetadata) {
//            if let singleSelectedItem = selectedItems.first {
//                EditMetadataView(model: model, selectedItem: .constant(singleSelectedItem))
//            }
//        }
//        // 批量编辑弹窗
//        .sheet(isPresented: $showBatchEdit) {
//            BatchEditMetadataView(
//                model: model,
//                selectedItems: Array(selectedItems) // 将 Set 转为 Array
//            )
//        }
    }
    
    // MARK: - Actions
    
//    func playPause() {
//        model.togglePlayPause()
//    }
//    
//    func deleteItems(at offsets: IndexSet) {
//        let urlsToRemove = offsets.map { model.playlist[$0].url }
//        model.removeFromPlaylist(urls: urlsToRemove)
//        model.savePlaylist()
//    }
//    
//    func openFile() {
//        let panel = NSOpenPanel()
//        panel.allowsMultipleSelection = false
//        panel.canChooseDirectories = false
////        panel.allowedFileTypes = ContentView.supportedPathExtensions
//        
//        if panel.runModal() == .OK, let url = panel.url {
//            model.play(url)
//        }
//    }
//    
//    func addFiles() {
//        let panel = NSOpenPanel()
//        panel.allowsMultipleSelection = true
//        panel.canChooseDirectories = false
////        panel.allowedFileTypes = ContentView.supportedPathExtensions
//        
//        if panel.runModal() == .OK {
//            model.addToPlaylist(urls: panel.urls)
//        }
//    }
//    
//    func analyzeFiles() {
//        let panel = NSOpenPanel()
//        panel.allowsMultipleSelection = true
//        panel.canChooseDirectories = false
////        panel.allowedFileTypes = ContentView.supportedPathExtensions
//        
//        if panel.runModal() == .OK {
//            model.analyzeFiles(urls: panel.urls)
//        }
//    }
//    
//    func exportWAVEFile() {
//        let panel = NSOpenPanel()
//        panel.allowsMultipleSelection = false
//        panel.canChooseDirectories = false
////        panel.allowedFileTypes = ContentView.supportedPathExtensions
//        
//        if panel.runModal() == .OK, let url = panel.url {
//            let destURL = url.deletingPathExtension().appendingPathExtension("wav")
//            if FileManager.default.fileExists(atPath: destURL.path) {
//                let alert = NSAlert()
//                alert.messageText = "是否覆盖现有文件？"
//                alert.informativeText = "同名文件已存在。"
//                alert.addButton(withTitle: "覆盖")
//                alert.addButton(withTitle: "取消")
//                
//                if alert.runModal() != .alertFirstButtonReturn {
//                    return
//                }
//            }
//            
//            model.exportWAVEFile(url: url)
//        }
//    }
//    
//    // MARK: - Helper
//    
//    func resizeImage(image: NSImage, maxSize: CGFloat) -> NSImage {
//        let aspectRatio = image.size.width / image.size.height
//        let newSize: NSSize
//        
//        if aspectRatio > 1 {
//            newSize = NSSize(width: maxSize, height: maxSize / aspectRatio)
//        } else {
//            newSize = NSSize(width: maxSize * aspectRatio, height: maxSize)
//        }
//        
//        // 使用 NSImage 的绘图方法
//        let newImage = NSImage(size: newSize)
//        newImage.lockFocus()
//        defer { newImage.unlockFocus() }
//        
//        let rect = NSRect(origin: .zero, size: newSize)
//        let imageRect = NSRect(origin: .zero, size: image.size)
//        image.draw(in: rect, from: imageRect, operation: .copy, fraction: 1.0)
//        
//        return newImage
//    }
//    
//    func formatTime(_ time: Double) -> String {
//        let totalSeconds = Int(abs(time))
//        let hours = totalSeconds / 3600
//        let minutes = (totalSeconds % 3600) / 60
//        let seconds = totalSeconds % 60
//        
//        if hours > 0 {
//            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
//        } else {
//            return String(format: "%02d:%02d", minutes, seconds)
//        }
//    }
}

