//
//  Metadata.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/11/24.
//

@preconcurrency import CSFBAudioEngine
import MediaPlayer
import SwiftUI

// MARK: - Metadata

// MARK: Definition

@Observable final class Metadata: Identifiable {
    typealias Entry = MetadataEntry

    enum State {
        case loading
        case fine
        case saving

        var isEditable: Bool {
            switch self {
            case .fine:
                true
            default:
                false
            }
        }

        var isLoaded: Bool {
            switch self {
            case .loading:
                false
            default:
                true
            }
        }

        var redactionReasons: RedactionReasons {
            switch self {
            case .loading:
                .placeholder
            default:
                []
            }
        }
    }

    var id: URL { url }
    let url: URL

    private(set) var properties: AudioProperties!
    private(set) var state: State
    private(set) var thumbnail: NSImage?

    var attachedPictures: Entry<Set<AttachedPicture>>!

    var title: Entry<String?>!
    var titleSortOrder: Entry<String?>!
    var artist: Entry<String?>!
    var artistSortOrder: Entry<String?>!
    var composer: Entry<String?>!
    var composerSortOrder: Entry<String?>!
    var genre: Entry<String?>!
    var genreSortOrder: Entry<String?>!
    var bpm: Entry<Int?>!

    var albumTitle: Entry<String?>!
    var albumTitleSortOrder: Entry<String?>!
    var albumArtist: Entry<String?>!
    var albumArtistSortOrder: Entry<String?>!

    var trackNumber: Entry<Int?>!
    var trackCount: Entry<Int?>!
    var discNumber: Entry<Int?>!
    var discCount: Entry<Int?>!

    var comment: Entry<String?>!
    var grouping: Entry<String?>!
    var isCompilation: Entry<Bool?>!

    var isrc: Entry<ISRC?>!
    var lyrics: Entry<String?>!
    var mcn: Entry<String?>!

    var musicBrainzRecordingID: Entry<UUID?>!
    var musicBrainzReleaseID: Entry<UUID?>!

    var rating: Entry<Int?>!
    var releaseDate: Entry<String?>!

    var replayGainAlbumGain: Entry<Double?>!
    var replayGainAlbumPeak: Entry<Double?>!
    var replayGainTrackGain: Entry<Double?>!
    var replayGainTrackPeak: Entry<Double?>!
    var replayGainReferenceLoudness: Entry<Double?>!

    var additional: Entry<AdditionalMetadata?>!

    init?(url: URL) {
        self.state = .loading
        self.url = url

        Task {
            try await self.update()
        }
    }

    fileprivate var restorables: [any Restorable] {
        guard state.isLoaded else { return [] }
        return [
            attachedPictures,
            title, titleSortOrder, artist, artistSortOrder, composer,
            composerSortOrder, genre, genreSortOrder, bpm,
            albumTitle, albumTitleSortOrder, albumArtist, albumArtistSortOrder,
            trackNumber, trackCount, discNumber, discCount,
            comment, grouping, isCompilation,
            isrc, lyrics, mcn,
            musicBrainzRecordingID, musicBrainzReleaseID,
            rating, releaseDate,
            replayGainAlbumGain, replayGainAlbumPeak, replayGainTrackGain,
            replayGainTrackPeak, replayGainReferenceLoudness
        ]
    }
}

// MARK: Loading Functions

private extension Metadata {
    func load(
        attachedPictures: Set<AttachedPicture> = [],
        title: String? = nil, titleSortOrder: String? = nil,
        artist: String? = nil, artistSortOrder: String? = nil,
        composer: String? = nil, composerSortOrder: String? = nil,
        genre: String? = nil, genreSortOrder: String? = nil,
        bpm: Int? = nil,
        albumTitle: String? = nil, albumTitleSortOrder: String? = nil,
        albumArtist: String? = nil, albumArtistSortOrder: String? = nil,
        trackNumber: Int? = nil, trackCount: Int? = nil,
        discNumber: Int? = nil, discCount: Int? = nil,
        comment: String? = nil,
        grouping: String? = nil,
        isCompilation: Bool? = nil,
        isrc: String? = nil,
        lyrics: String? = nil,
        mcn: String? = nil,
        musicBrainzRecordingID: String? = nil,
        musicBrainzReleaseID: String? = nil,
        rating: Int? = nil,
        releaseDate: String? = nil,
        replayGainAlbumGain: Double? = nil, replayGainAlbumPeak: Double? = nil,
        replayGainTrackGain: Double? = nil, replayGainTrackPeak: Double? = nil,
        replayGainReferenceLoudness: Double? = nil,
        additional: AdditionalMetadata? = nil
    ) {
        self.attachedPictures = .init(
            attachedPictures
        )

        self.title = .init(
            title
        )
        self.titleSortOrder = .init(
            titleSortOrder
        )
        self.artist = .init(
            artist
        )
        self.artistSortOrder = .init(
            artistSortOrder
        )
        self.composer = .init(
            composer
        )
        self.composerSortOrder = .init(
            composerSortOrder
        )
        self.genre = .init(
            genre
        )
        self.genreSortOrder = .init(
            genreSortOrder
        )
        self.bpm = .init(
            bpm
        )

        self.albumTitle = .init(
            albumTitle
        )
        self.albumTitleSortOrder = .init(
            albumTitleSortOrder
        )
        self.albumArtist = .init(
            albumArtist
        )
        self.albumArtistSortOrder = .init(
            albumArtistSortOrder
        )

        self.trackNumber = .init(
            trackNumber
        )
        self.trackCount = .init(
            trackCount
        )
        self.discNumber = .init(
            discNumber
        )
        self.discCount = .init(
            discCount
        )

        self.comment = .init(
            comment
        )
        self.grouping = .init(
            grouping
        )
        self.isCompilation = .init(
            isCompilation
        )

        self.isrc = .init(
            isrc.flatMap { ISRC(parsing: $0) }
        )
        self.lyrics = .init(
            lyrics
        )
        self.mcn = .init(
            mcn
        )

        self.musicBrainzRecordingID = .init(
            musicBrainzRecordingID.flatMap(UUID.init(uuidString:))
        )
        self.musicBrainzReleaseID = .init(
            musicBrainzReleaseID.flatMap(UUID.init(uuidString:))
        )

        self.rating = .init(
            rating
        )
        self.releaseDate = .init(
            releaseDate
        )

        self.replayGainAlbumGain = .init(
            replayGainAlbumGain
        )
        self.replayGainAlbumPeak = .init(
            replayGainAlbumPeak
        )
        self.replayGainTrackGain = .init(
            replayGainTrackGain
        )
        self.replayGainTrackPeak = .init(
            replayGainTrackPeak
        )
        self.replayGainReferenceLoudness = .init(
            replayGainReferenceLoudness
        )

        self.additional = .init(
            additional
        )
    }

    func load(from metadata: AudioMetadata?) {
        load(
            attachedPictures: metadata?.attachedPictures ?? [],
            title: metadata?.title,
            titleSortOrder: metadata?.titleSortOrder,
            artist: metadata?.artist,
            artistSortOrder: metadata?.artistSortOrder,
            composer: metadata?.composer,
            composerSortOrder: metadata?.composerSortOrder,
            genre: metadata?.genre,
            genreSortOrder: metadata?.genreSortOrder,
            bpm: metadata?.bpm,
            albumTitle: metadata?.albumTitle,
            albumTitleSortOrder: metadata?.albumTitleSortOrder,
            albumArtist: metadata?.albumArtist,
            albumArtistSortOrder: metadata?.albumArtistSortOrder,
            trackNumber: metadata?.trackNumber,
            trackCount: metadata?.trackTotal,
            discNumber: metadata?.discNumber,
            discCount: metadata?.discTotal,
            comment: metadata?.comment,
            grouping: metadata?.grouping,
            isCompilation: metadata?.isCompilation,
            isrc: metadata?.isrc,
            lyrics: metadata?.lyrics,
            mcn: metadata?.mcn,
            musicBrainzRecordingID: metadata?.musicBrainzRecordingID,
            musicBrainzReleaseID: metadata?.musicBrainzReleaseID,
            rating: metadata?.rating,
            releaseDate: metadata?.releaseDate,
            replayGainAlbumGain: metadata?.replayGainAlbumGain,
            replayGainAlbumPeak: metadata?.replayGainAlbumPeak,
            replayGainTrackGain: metadata?.replayGainTrackGain,
            replayGainTrackPeak: metadata?.replayGainTrackPeak,
            replayGainReferenceLoudness: metadata?.replayGainReferenceLoudness,
            additional: metadata?.additionalMetadata.map(
                AdditionalMetadata.init(_:))
        )
    }

    func pack() -> AudioMetadata {
        let metadata = AudioMetadata()

        metadata.title = title.current
        metadata.titleSortOrder = titleSortOrder.current
        metadata.artist = artist.current
        metadata.artistSortOrder = artistSortOrder.current
        metadata.composer = composer.current
        metadata.composerSortOrder = composerSortOrder.current
        metadata.genre = genre.current
        metadata.genreSortOrder = genreSortOrder.current
        metadata.bpm = bpm.current
        metadata.albumTitle = albumTitle.current
        metadata.albumArtist = albumArtist.current
        metadata.trackNumber = trackNumber.current
        metadata.trackTotal = trackCount.current
        metadata.discNumber = discNumber.current
        metadata.discTotal = discCount.current
        metadata.comment = comment.current
        metadata.grouping = grouping.current
        metadata.isCompilation = isCompilation.current
        metadata.isrc = isrc.current?.formatted()
        metadata.lyrics = lyrics.current
        metadata.mcn = mcn.current
        metadata.musicBrainzRecordingID =
            musicBrainzRecordingID.current?.uuidString
        metadata.musicBrainzReleaseID = musicBrainzReleaseID.current?.uuidString
        metadata.rating = rating.current
        metadata.releaseDate = releaseDate.current
        metadata.replayGainAlbumGain = replayGainAlbumGain.current
        metadata.replayGainAlbumPeak = replayGainAlbumPeak.current
        metadata.replayGainTrackGain = replayGainTrackGain.current
        metadata.replayGainTrackPeak = replayGainTrackPeak.current
        metadata.replayGainReferenceLoudness =
            replayGainReferenceLoudness.current
        metadata.additionalMetadata = additional.current

        attachedPictures.current.forEach(metadata.attachPicture(_:))

        return metadata
    }
}

// MARK: Manipulating Functions

extension Metadata: Modifiable {
    var isModified: Bool {
        guard state.isLoaded else { return false }
        return !restorables.filter(\.isModified).isEmpty
    }
}

extension Metadata {
    func restore() {
        guard state.isLoaded else { return }
        for var restorable in self.restorables {
            restorable.restore()
        }

        Task {
            await generateThumbnail()
        }
    }

    func apply() {
        guard state.isLoaded else { return }
        for var restorable in self.restorables {
            restorable.apply()
        }

        Task {
            await generateThumbnail()
            updateNowPlayingInfo()
        }
    }

    func generateThumbnail() async {
        guard state.isLoaded else {
            thumbnail = nil
            return
        }

        if let image = ThumbnailMaker.getCover(from: attachedPictures.current)?.image {
            thumbnail = await ThumbnailMaker.make(image)
        }
    }

    func update() async throws {
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }

        let file = try AudioFile(readingPropertiesAndMetadataFrom: url)
        properties = file.properties
        load(from: file.metadata)

        switch state {
        case .loading:
            print("Loaded metadata from \(url)")
        default:
            print("Updated metadata from \(url)")
        }

        state = .fine
        await generateThumbnail()
    }

    func write() async throws {
        guard state.isEditable, isModified else { return }
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { self.url.stopAccessingSecurityScopedResource() }

        state = .saving
        apply()
        print("Started writing metadata to \(url)")

        let file = try AudioFile(url: url)
        file.metadata = pack()

        if file.metadata.comment != nil {
            try file.writeMetadata()
        } else {
            // This is crucial for `.flac` file types
            // In these files, if all fields except `attachedPictures` field are `nil`, audio decoding will encounter great issues after writing metadata
            // so hereby always providing an empty `comment` if it is `nil`
            file.metadata.comment = ""
            try file.writeMetadata()
        }

        state = .fine
        print("Successfully written metadata to \(url)")
    }

    subscript<V>(extracting keyPath: WritableKeyPath<Metadata, Entry<V>>)
        -> MetadataBatchEditingEntry<V>? {
        guard state.isLoaded else { return nil }
        return .init(keyPath: keyPath, metadata: self)
    }
}

// MARK: Extensions

extension Metadata {
    static func splitArtists(from artist: String) -> [Substring] {
        artist.split(separator: /[\/,]\s*/)
    }
}

extension Metadata: Equatable {
    static func == (lhs: Metadata, rhs: Metadata) -> Bool {
        lhs.id == rhs.id
    }
}

extension Metadata: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Metadata {
    static func fallbackTitle(url: URL) -> String {
        String(url.lastPathComponent.dropLast(url.pathExtension.count + 1))
    }

    func updateNowPlayingInfo() {
        let infoCenter = MPNowPlayingInfoCenter.default()
        var info = infoCenter.nowPlayingInfo ?? .init()

        if state.isLoaded {
            updateNowPlayingInfo(for: &info)
        } else {
            Self.resetNowPlayingInfo(for: &info)
        }

        infoCenter.nowPlayingInfo = info
    }

    func updateNowPlayingInfo(for dict: inout [String: Any]) {
        guard state.isLoaded else {
            return Self.resetNowPlayingInfo(for: &dict)
        }

        dict[MPMediaItemPropertyArtwork] = ThumbnailMaker.getCover(
            from: attachedPictures.initial
        )
        .flatMap(\.image)
        .map(\.mediaItemArtwork)

        dict[MPMediaItemPropertyTitle] = title.initial ?? Self.fallbackTitle(url: url)
        dict[MPMediaItemPropertyArtist] = artist.initial
        dict[MPMediaItemPropertyComposer] = composer.initial
        dict[MPMediaItemPropertyGenre] = genre.initial
        dict[MPMediaItemPropertyBeatsPerMinute] = bpm.initial

        dict[MPMediaItemPropertyAlbumTitle] = albumTitle.initial
        dict[MPMediaItemPropertyAlbumArtist] = albumArtist.initial

        dict[MPMediaItemPropertyAlbumTrackNumber] = trackNumber.initial
        dict[MPMediaItemPropertyAlbumTrackCount] = trackCount.initial
        dict[MPMediaItemPropertyDiscNumber] = discNumber.initial
        dict[MPMediaItemPropertyDiscCount] = discCount.initial

        dict[MPMediaItemPropertyComments] = comment.initial
        dict[MPMediaItemPropertyUserGrouping] = grouping.initial
        dict[MPMediaItemPropertyIsCompilation] = isCompilation.initial

        dict[MPNowPlayingInfoPropertyInternationalStandardRecordingCode] =
            isrc.initial
        dict[MPMediaItemPropertyLyrics] = lyrics.initial

        dict[MPMediaItemPropertyReleaseDate] = releaseDate.initial
    }

    static func resetNowPlayingInfo() {
        let infoCenter = MPNowPlayingInfoCenter.default()
        var info = infoCenter.nowPlayingInfo ?? .init()

        Self.resetNowPlayingInfo(for: &info)

        infoCenter.nowPlayingInfo = info
    }

    static func resetNowPlayingInfo(for dict: inout [String: Any]) {
        dict[MPMediaItemPropertyArtwork] = nil

        dict[MPMediaItemPropertyTitle] = nil
        dict[MPMediaItemPropertyArtist] = nil
        dict[MPMediaItemPropertyComposer] = nil
        dict[MPMediaItemPropertyGenre] = nil
        dict[MPMediaItemPropertyBeatsPerMinute] = nil

        dict[MPMediaItemPropertyAlbumTitle] = nil
        dict[MPMediaItemPropertyAlbumArtist] = nil

        dict[MPMediaItemPropertyAlbumTrackNumber] = nil
        dict[MPMediaItemPropertyAlbumTrackCount] = nil
        dict[MPMediaItemPropertyDiscNumber] = nil
        dict[MPMediaItemPropertyDiscCount] = nil

        dict[MPMediaItemPropertyComments] = nil
        dict[MPMediaItemPropertyUserGrouping] = nil
        dict[MPMediaItemPropertyIsCompilation] = nil

        dict[MPNowPlayingInfoPropertyInternationalStandardRecordingCode] = nil
        dict[MPMediaItemPropertyLyrics] = nil

        dict[MPMediaItemPropertyReleaseDate] = nil
    }
}
