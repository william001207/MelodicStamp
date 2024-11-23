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
    @State var player: PlayerModel
    @Binding var selectedItem: PlaylistItem?

    @State private var title: String = ""
    @State private var titleSortOrder: String = ""
    @State private var artist: String = ""
    @State private var artistSortOrder: String = ""
    @State private var albumTitle: String = ""
    @State private var albumTitleSortOrder: String = ""
    @State private var albumArtist: String = ""
    @State private var albumArtistSortOrder: String = ""
    @State private var trackNumber: String = ""
    @State private var trackTotal: String = ""
    @State private var discNumber: String = ""
    @State private var discTotal: String = ""
    @State private var genre: String = ""
    @State private var genreSortOrder: String = ""
    @State private var bpm: String = ""
    @State private var comment: String = ""
    @State private var composer: String = ""
    @State private var composerSortOrder: String = ""
    @State private var grouping: String = ""
    @State private var isCompilation: Bool = false
    @State private var isrc: String = ""
    @State private var lyrics: String = ""
    @State private var mcn: String = ""
    @State private var musicBrainzRecordingID: String = ""
    @State private var musicBrainzReleaseID: String = ""
    @State private var rating: String = ""
    @State private var releaseDate: String = ""
    @State private var replayGainAlbumGain: String = ""
    @State private var replayGainAlbumPeak: String = ""
    @State private var replayGainTrackGain: String = ""
    @State private var replayGainTrackPeak: String = ""
    @State private var replayGainReferenceLoudness: String = ""
    
    @State private var coverImage: NSImage? = nil
    @State private var showImagePicker: Bool = false

    var body: some View {
        ScrollView {
            LazyVStack {
                Form {
                    Section(header: Text("封面")) {
                        VStack {
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
                        TextField("标题排序", text: $titleSortOrder)
                        TextField("艺术家", text: $artist)
                        TextField("艺术家排序", text: $artistSortOrder)
                        TextField("专辑", text: $albumTitle)
                        TextField("专辑排序", text: $albumTitleSortOrder)
                        TextField("专辑艺术家", text: $albumArtist)
                        TextField("专辑艺术家排序", text: $albumArtistSortOrder)
                        TextField("音轨号", text: $trackNumber)
                        TextField("音轨总数", text: $trackTotal)
                        TextField("碟号", text: $discNumber)
                        TextField("碟总数", text: $discTotal)
                        TextField("风格", text: $genre)
                        TextField("风格排序", text: $genreSortOrder)
                    }
                    
                    Section(header: Text("创作信息")) {
                        TextField("作曲", text: $composer)
                        TextField("作曲排序", text: $composerSortOrder)
                        TextField("分组", text: $grouping)
                        TextField("国际标准音像代码 (ISRC)", text: $isrc)
                    }
                    
                    Section(header: Text("动态信息")) {
                        TextField("节拍 (BPM)", text: $bpm)
                        TextField("评价", text: $rating)
                        TextField("发行日期", text: $releaseDate)
                        TextField("音轨增益", text: $replayGainTrackGain)
                        TextField("音轨峰值", text: $replayGainTrackPeak)
                        TextField("专辑增益", text: $replayGainAlbumGain)
                        TextField("专辑峰值", text: $replayGainAlbumPeak)
                        TextField("参考响度", text: $replayGainReferenceLoudness)
                    }
                    
                    Section(header: Text("注释")) {
                        TextEditor(text: $comment)
                            .frame(height: 100)
                    }
                    
                    Section(header: Text("歌词")) {
                        TextEditor(text: $lyrics)
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
        }
        .onAppear(perform: loadMetadata)
        .frame(width: 400, height: 800)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $coverImage)
        }
    }

    func loadMetadata() {
        guard let item = selectedItem else { return }
        title = item.metadata.title ?? ""
        titleSortOrder = item.metadata.titleSortOrder ?? ""
        artist = item.metadata.artist ?? ""
        artistSortOrder = item.metadata.artistSortOrder ?? ""
        albumTitle = item.metadata.albumTitle ?? ""
        albumTitleSortOrder = item.metadata.albumTitleSortOrder ?? ""
        albumArtist = item.metadata.albumArtist ?? ""
        albumArtistSortOrder = item.metadata.albumArtistSortOrder ?? ""
        trackNumber = item.metadata.trackNumber?.description ?? ""
        trackTotal = item.metadata.trackTotal?.description ?? ""
        discNumber = item.metadata.discNumber?.description ?? ""
        discTotal = item.metadata.discTotal?.description ?? ""
        genre = item.metadata.genre ?? ""
        genreSortOrder = item.metadata.genreSortOrder ?? ""
        bpm = item.metadata.bpm?.description ?? ""
        comment = item.metadata.comment ?? ""
        composer = item.metadata.composer ?? ""
        composerSortOrder = item.metadata.composerSortOrder ?? ""
        grouping = item.metadata.grouping ?? ""
        isCompilation = item.metadata.isCompilation ?? false
        isrc = item.metadata.isrc ?? ""
        lyrics = item.metadata.lyrics ?? ""
        mcn = item.metadata.mcn ?? ""
        musicBrainzRecordingID = item.metadata.musicBrainzRecordingID ?? ""
        musicBrainzReleaseID = item.metadata.musicBrainzReleaseID ?? ""
        rating = item.metadata.rating?.description ?? ""
        releaseDate = item.metadata.releaseDate ?? ""
        replayGainAlbumGain = item.metadata.replayGainAlbumGain?.description ?? ""
        replayGainAlbumPeak = item.metadata.replayGainAlbumPeak?.description ?? ""
        replayGainTrackGain = item.metadata.replayGainTrackGain?.description ?? ""
        replayGainTrackPeak = item.metadata.replayGainTrackPeak?.description ?? ""
        replayGainReferenceLoudness = item.metadata.replayGainReferenceLoudness?.description ?? ""

        if let picture = item.metadata.attachedPictures.first?.image {
            coverImage = picture
        }
    }

    func isFormValid() -> Bool {
        return !title.isEmpty
    }

    func saveMetadata() {
        guard var item = selectedItem else { return }
        item.metadata.title = title
        item.metadata.titleSortOrder = titleSortOrder
        item.metadata.artist = artist
        item.metadata.artistSortOrder = artistSortOrder
        item.metadata.albumTitle = albumTitle
        item.metadata.albumTitleSortOrder = albumTitleSortOrder
        item.metadata.albumArtist = albumArtist
        item.metadata.albumArtistSortOrder = albumArtistSortOrder
        item.metadata.trackNumber = Int(trackNumber)
        item.metadata.trackTotal = Int(trackTotal)
        item.metadata.discNumber = Int(discNumber)
        item.metadata.discTotal = Int(discTotal)
        item.metadata.genre = genre
        item.metadata.genreSortOrder = genreSortOrder
        item.metadata.bpm = Int(bpm)
        item.metadata.comment = comment
        item.metadata.composer = composer
        item.metadata.composerSortOrder = composerSortOrder
        item.metadata.grouping = grouping
        item.metadata.isCompilation = isCompilation
        item.metadata.isrc = isrc
        item.metadata.lyrics = lyrics
        item.metadata.mcn = mcn
        item.metadata.musicBrainzRecordingID = musicBrainzRecordingID
        item.metadata.musicBrainzReleaseID = musicBrainzReleaseID
        item.metadata.rating = Int(rating)
        item.metadata.releaseDate = releaseDate
        item.metadata.replayGainAlbumGain = Double(replayGainAlbumGain)
        item.metadata.replayGainAlbumPeak = Double(replayGainAlbumPeak)
        item.metadata.replayGainTrackGain = Double(replayGainTrackGain)
        item.metadata.replayGainTrackPeak = Double(replayGainTrackPeak)
        item.metadata.replayGainReferenceLoudness = Double(replayGainReferenceLoudness)

//        // 更新播放列表
//        if let index = player.playlist.firstIndex(where: { $0.id == item.id }) {
//            player.playlist[index] = item
//        }

        do {
            let audioFile = try AudioFile(url: item.url)
            var metadata = audioFile.metadata

            if let newCover = coverImage {
                let picture = AttachedPicture(imageData: newCover.tiffRepresentation ?? Data())
                metadata.attachPicture(picture)
            }

            metadata = item.metadata
            audioFile.metadata = metadata
            try audioFile.writeMetadata()
        } catch {
//            player.handleError(error)
        }
    }
}
