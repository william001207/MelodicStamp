//
//  EditMetadataView.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/20.
//

import SwiftUI
import CSFBAudioEngine

struct EditMetadataView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: PlayerViewModel
    @Binding var selectedItem: PlaylistItem?

    @State private var title: String = ""
    @State private var artist: String = ""
    @State private var albumTitle: String = ""
    @State private var year: String = ""
    @State private var trackNumber: String = ""
    @State private var diskNumber: String = ""
    @State private var genre: String = ""
    @State private var albumArtist: String = ""
    @State private var composer: String = ""
    @State private var lyricist: String = ""
    @State private var comments: String = ""
    
    @State private var coverImage: NSImage? = nil
    @State private var showImagePicker: Bool = false

    var body: some View {
        VStack {
            Form {
                Section(header: Text("封面")) {
                    HStack {
                        if let cover = coverImage {
                            Image(nsImage: cover)
                                .resizable()
                                .frame(width: 100, height: 100)
                                .cornerRadius(5)
                        } else {
                            Image(systemName: "photo")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.gray)
                        }
                        Button("选择封面") {
                            showImagePicker = true
                        }
                    }
                }
                Section(header: Text("基本信息")) {
                    TextField("标题", text: $title)
                    TextField("艺术家", text: $artist)
                    TextField("专辑", text: $albumTitle)
                    TextField("专辑艺术家", text: $albumArtist)
//                    TextField("年份", text: $year)
                    TextField("音轨号", text: $trackNumber)
//                    TextField("碟号", text: $diskNumber)
                    TextField("风格", text: $genre)
                    
                }

                Section(header: Text("创作信息")) {
                    TextField("作曲", text: $composer)
//                    TextField("作词", text: $lyricist)
                }

                Section(header: Text("注释")) {
                    TextEditor(text: $comments)
                        .frame(height: 100)
                }
            }
            .padding()

            HStack {
                Spacer()
                Button("取消") {
                    presentationMode.wrappedValue.dismiss()
                }
                Button("保存") {
                    saveMetadata()
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(!isFormValid())
            }
            .padding()
        }
        .onAppear(perform: loadMetadata)
        .frame(width: 400, height: 600)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $coverImage)
        }
    }

    // 加载选定项的元信息到本地状态
    func loadMetadata() {
        guard let item = selectedItem else { return }
        self.title = item.metadata.title ?? ""
        self.artist = item.metadata.artist ?? ""
        self.albumTitle = item.metadata.albumTitle ?? ""
//        self.year = item.metadata.year != nil ? String(item.metadata.year!) : ""
        self.trackNumber = item.metadata.trackNumber != nil ? String(item.metadata.trackNumber!) : ""
//        self.diskNumber = item.metadata.diskNumber != nil ? String(item.metadata.diskNumber!) : ""
        self.genre = item.metadata.genre ?? ""
        self.albumArtist = item.metadata.albumArtist ?? ""
        self.composer = item.metadata.composer ?? ""
//        self.lyricist = item.metadata.lyricist ?? ""
        self.comments = item.metadata.comment ?? ""
        
        if let picture = item.metadata.attachedPictures.first?.image {
            self.coverImage = picture
        }
    }

    // 检查表单是否有效
    func isFormValid() -> Bool {
        // 可以根据需要添加更多验证规则
        return !title.isEmpty && !artist.isEmpty
    }

    // 保存元信息
    func saveMetadata() {
        guard var item = selectedItem else { return }
        item.metadata.title = title
        item.metadata.artist = artist
        item.metadata.albumTitle = albumTitle
//        item.metadata.year = Int(year)
        item.metadata.trackNumber = Int(trackNumber)
//        item.metadata.diskNumber = Int(diskNumber)
        item.metadata.genre = genre
        item.metadata.albumArtist = albumArtist
        item.metadata.composer = composer
//        item.metadata.lyricist = lyricist
        item.metadata.comment = comments

        // 更新播放列表
        if let index = viewModel.playlist.firstIndex(where: { $0.id == item.id }) {
            viewModel.playlist[index] = item
        }

        // 保存到文件
        do {
            let audioFile = try AudioFile(url: item.url)
            var metadata = audioFile.metadata
            
            if let newCover = coverImage {
                let picture = AttachedPicture(imageData: newCover.tiffRepresentation ?? Data())
                metadata.attachPicture(picture)
            }

            // 更新元信息字段
            metadata.title = title
            metadata.artist = artist
            metadata.albumTitle = albumTitle
//            metadata.year = Int(year) ?? 0
            metadata.trackNumber = Int(trackNumber) ?? 0
//            metadata.diskNumber = Int(diskNumber) ?? 0
            metadata.genre = genre
            metadata.albumArtist = albumArtist
            metadata.composer = composer
//            metadata.lyricist = lyricist
            metadata.comment = comments

            // 赋值回音频文件
            audioFile.metadata = metadata

            // 写入元信息
            try audioFile.writeMetadata()
        } catch {
            viewModel.handleError(error)
        }
    }
}

