//
//  BatchEditMetadataView.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2024/11/20.
//

import SwiftUI
import CSFBAudioEngine

struct BatchEditMetadataView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var model: PlayerModel
    var selectedItems: [PlaylistItem]

    // 批量编辑字段（可选项）
    @State private var coverImage: NSImage? = nil
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

    // 确定哪些字段被编辑
    @State private var isImageEdited: Bool = false
    @State private var isTitleEdited: Bool = false
    @State private var isArtistEdited: Bool = false
    @State private var isAlbumTitleEdited: Bool = false
    @State private var isYearEdited: Bool = false
    @State private var isTrackNumberEdited: Bool = false
    @State private var isDiskNumberEdited: Bool = false
    @State private var isGenreEdited: Bool = false
    @State private var isAlbumArtistEdited: Bool = false
    @State private var isComposerEdited: Bool = false
    @State private var isLyricistEdited: Bool = false
    @State private var isCommentsEdited: Bool = false
    
    @State private var showImagePicker: Bool = false

    var body: some View {
        VStack {
            Form {
                Section(header: Text("批量编辑")) {
                    Toggle("封面", isOn: $isTitleEdited)
                    if isImageEdited {
                        Button("选择封面") {
                            showImagePicker = true
                        }
                    }
                    
                    Toggle("标题", isOn: $isTitleEdited)
                    if isTitleEdited {
                        TextField("标题", text: $title)
                    }

                    Toggle("艺术家", isOn: $isArtistEdited)
                    if isArtistEdited {
                        TextField("艺术家", text: $artist)
                    }

                    Toggle("专辑", isOn: $isAlbumTitleEdited)
                    if isAlbumTitleEdited {
                        TextField("专辑", text: $albumTitle)
                    }

//                    Toggle("年份", isOn: $isYearEdited)
//                    if isYearEdited {
//                        TextField("年份", text: $year)
//                    }

                    Toggle("音轨号", isOn: $isTrackNumberEdited)
                    if isTrackNumberEdited {
                        TextField("音轨号", text: $trackNumber)
                    }

//                    Toggle("碟号", isOn: $isDiskNumberEdited)
//                    if isDiskNumberEdited {
//                        TextField("碟号", text: $diskNumber)
//                    }

                    Toggle("风格", isOn: $isGenreEdited)
                    if isGenreEdited {
                        TextField("风格", text: $genre)
                    }

                    Toggle("专辑艺术家", isOn: $isAlbumArtistEdited)
                    if isAlbumArtistEdited {
                        TextField("专辑艺术家", text: $albumArtist)
                    }

                    Toggle("作曲", isOn: $isComposerEdited)
                    if isComposerEdited {
                        TextField("作曲", text: $composer)
                    }

//                    Toggle("作词", isOn: $isLyricistEdited)
//                    if isLyricistEdited {
//                        TextField("作词", text: $lyricist)
//                    }

                    Toggle("注释", isOn: $isCommentsEdited)
                    if isCommentsEdited {
                        TextEditor(text: $comments)
                            .frame(height: 100)
                    }
                }
            }
            .padding()

            HStack {
                Spacer()
                Button("取消") {
                    presentationMode.wrappedValue.dismiss()
                }
                Button("保存") {
                    saveBatchMetadata()
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(!isAnyFieldEdited())
            }
            .padding()
        }
        .frame(width: 500, height: 800)
    }

    // 检查是否有任何字段被编辑
    func isAnyFieldEdited() -> Bool {
        isTitleEdited || isArtistEdited || isAlbumTitleEdited ||
        isYearEdited || isTrackNumberEdited || isDiskNumberEdited ||
        isGenreEdited || isAlbumArtistEdited || isComposerEdited ||
        isLyricistEdited || isCommentsEdited
    }

    // 保存批量元信息
    func saveBatchMetadata() {
        for item in selectedItems {
            var metadata = item.metadata
            
            if let newCover = coverImage {
                let picture = AttachedPicture(imageData: newCover.tiffRepresentation ?? Data())
                metadata.attachPicture(picture)
            }
            
            // 根据编辑状态更新对应字段
            if isTitleEdited {
                metadata.title = title
            }
            if isArtistEdited {
                metadata.artist = artist
            }
            if isAlbumTitleEdited {
                metadata.albumTitle = albumTitle
            }
//            if isYearEdited {
//                metadata.year = Int(year) // 确保年是整数
//            }
            if isTrackNumberEdited {
                metadata.trackNumber = Int(trackNumber)
            }
//            if isDiskNumberEdited {
//                metadata.diskNumber = Int(diskNumber)
//            }
            if isGenreEdited {
                metadata.genre = genre
            }
            if isAlbumArtistEdited {
                metadata.albumArtist = albumArtist
            }
            if isComposerEdited {
                metadata.composer = composer
            }
//            if isLyricistEdited {
//                metadata.lyricist = lyricist
//            }
            if isCommentsEdited {
                metadata.comment = comments
            }

//            // 保存到文件
//            do {
//                let audioFile = try AudioFile(url: item.url)
//                
//                // 写入元信息
//                audioFile.metadata = metadata
//                try audioFile.writeMetadata()
//                
//                // 更新播放列表中的元信息
//                if let index = viewModel.playlist.firstIndex(where: { $0.id == item.id }) {
//                    viewModel.playlist[index].metadata = metadata
//                }
//            } catch {
//                viewModel.handleError(error)
//            }
        }
    }
}
