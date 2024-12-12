//
//  Metadata.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/11/24.
//

@preconcurrency import CSFBAudioEngine
import SwiftUI

// MARK: - Metadata

// MARK: Definition

@Observable final class Metadata: Identifiable, Sendable {
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
    var trackTotal: Entry<Int?>!
    var discNumber: Entry<Int?>!
    var discTotal: Entry<Int?>!

    var comment: Entry<String?>!
    var grouping: Entry<String?>!
    var isCompilation: Entry<Bool?>!

    var isrc: Entry<String?>!
    var lyrics: Entry<String?>!
    var mcn: Entry<String?>!

    var musicBrainzRecordingID: Entry<String?>!
    var musicBrainzReleaseID: Entry<String?>!

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
            trackNumber, trackTotal, discNumber, discTotal,
            comment, grouping, isCompilation,
            isrc, lyrics, mcn,
            musicBrainzRecordingID, musicBrainzReleaseID,
            rating, releaseDate,
            replayGainAlbumGain, replayGainAlbumPeak, replayGainTrackGain,
            replayGainTrackPeak, replayGainReferenceLoudness,
        ]
    }
}

// MARK: Loading Functions

extension Metadata {
    fileprivate func load(
        attachedPictures: Set<AttachedPicture> = [],
        title: String? = nil, titleSortOrder: String? = nil,
        artist: String? = nil, artistSortOrder: String? = nil,
        composer: String? = nil, composerSortOrder: String? = nil,
        genre: String? = nil, genreSortOrder: String? = nil,
        bpm: Int? = nil,
        albumTitle: String? = nil, albumTitleSortOrder: String? = nil,
        albumArtist: String? = nil, albumArtistSortOrder: String? = nil,
        trackNumber: Int? = nil, trackTotal: Int? = nil,
        discNumber: Int? = nil, discTotal: Int? = nil,
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
        self.attachedPictures = .init(attachedPictures)
        self.title = .init(title)
        self.titleSortOrder = .init(titleSortOrder)
        self.artist = .init(artist)
        self.artistSortOrder = .init(artistSortOrder)
        self.composer = .init(composer)
        self.composerSortOrder = .init(composerSortOrder)
        self.genre = .init(genre)
        self.genreSortOrder = .init(genreSortOrder)
        self.bpm = .init(bpm)
        self.albumTitle = .init(albumTitle)
        self.albumTitleSortOrder = .init(albumTitleSortOrder)
        self.albumArtist = .init(albumArtist)
        self.albumArtistSortOrder = .init(albumArtistSortOrder)
        self.trackNumber = .init(trackNumber)
        self.trackTotal = .init(trackTotal)
        self.discNumber = .init(discNumber)
        self.discTotal = .init(discTotal)
        self.comment = .init(comment)
        self.grouping = .init(grouping)
        self.isCompilation = .init(isCompilation)
        self.isrc = .init(isrc)
        self.lyrics = .init(lyrics)
        self.mcn = .init(mcn)
        self.musicBrainzRecordingID = .init(musicBrainzRecordingID)
        self.musicBrainzReleaseID = .init(musicBrainzReleaseID)
        self.rating = .init(rating)
        self.releaseDate = .init(releaseDate)
        self.replayGainAlbumGain = .init(replayGainAlbumGain)
        self.replayGainAlbumPeak = .init(replayGainAlbumPeak)
        self.replayGainTrackGain = .init(replayGainTrackGain)
        self.replayGainTrackPeak = .init(replayGainTrackPeak)
        self.replayGainReferenceLoudness = .init(replayGainReferenceLoudness)
        self.additional = .init(additional)
    }

    fileprivate func load(from metadata: AudioMetadata?) {
        load(
            attachedPictures: metadata?.attachedPictures ?? [],
            title: metadata?.title, titleSortOrder: metadata?.titleSortOrder,
            artist: metadata?.artist,
            artistSortOrder: metadata?.artistSortOrder,
            composer: metadata?.composer,
            composerSortOrder: metadata?.composerSortOrder,
            genre: metadata?.genre, genreSortOrder: metadata?.genreSortOrder,
            bpm: metadata?.bpm,
            albumTitle: metadata?.albumTitle,
            albumTitleSortOrder: metadata?.albumTitleSortOrder,
            albumArtist: metadata?.albumArtist,
            albumArtistSortOrder: metadata?.albumArtistSortOrder,
            trackNumber: metadata?.trackNumber,
            trackTotal: metadata?.trackTotal,
            discNumber: metadata?.discNumber, discTotal: metadata?.discTotal,
            comment: metadata?.comment,
            grouping: metadata?.grouping,
            isCompilation: metadata?.isCompilation,
            isrc: metadata?.isrc,
            lyrics: metadata?.lyrics,
            mcn: metadata?.mcn,
            musicBrainzRecordingID: metadata?.musicBrainzRecordingID,
            musicBrainzReleaseID: metadata?.musicBrainzReleaseID,
            rating: metadata?.rating, releaseDate: metadata?.releaseDate,
            replayGainAlbumGain: metadata?.replayGainAlbumGain,
            replayGainAlbumPeak: metadata?.replayGainAlbumPeak,
            replayGainTrackGain: metadata?.replayGainTrackGain,
            replayGainTrackPeak: metadata?.replayGainTrackPeak,
            replayGainReferenceLoudness: metadata?.replayGainReferenceLoudness,
            additional: metadata?.additionalMetadata.map(
                AdditionalMetadata.init(_:))
        )
    }

    fileprivate func pack() -> AudioMetadata {
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
        metadata.trackTotal = trackTotal.current
        metadata.discNumber = discNumber.current
        metadata.discTotal = discTotal.current
        metadata.comment = comment.current
        metadata.grouping = grouping.current
        metadata.isCompilation = isCompilation.current
        metadata.isrc = isrc.current
        metadata.lyrics = lyrics.current
        metadata.mcn = mcn.current
        metadata.musicBrainzRecordingID = musicBrainzRecordingID.current
        metadata.musicBrainzReleaseID = musicBrainzReleaseID.current
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
            generateThumbnail()
        }
    }

    func apply() {
        guard state.isLoaded else { return }
        for var restorable in self.restorables {
            restorable.apply()
        }
        
        Task {
            generateThumbnail()
        }
    }
    
    func generateThumbnail() {
        guard state.isLoaded else {
            thumbnail = nil
            return
        }
        
        if let image = ThumbnailMaker.getCoverImage(from: attachedPictures.current)?.image {
            thumbnail = ThumbnailMaker.make(image)
        }
    }

    func update() async throws {
        try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self else { return continuation.resume() }
            guard url.startAccessingSecurityScopedResource() else {
                return continuation.resume()
            }
            defer { url.stopAccessingSecurityScopedResource() }

            do {
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
                generateThumbnail()

                continuation.resume()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    func write() async throws {
        try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self, state.isEditable, isModified else {
                return continuation.resume()
            }
            guard url.startAccessingSecurityScopedResource() else {
                return continuation.resume()
            }
            defer { self.url.stopAccessingSecurityScopedResource() }

            do {
                state = .saving
                apply()
                print("Started writing metadata to \(url)")

                let file = try AudioFile(url: url)
                file.metadata = pack()

                if file.metadata.comment != nil {
                    try file.writeMetadata()
                } else {
                    // this is crucial for `.flac` file types
                    // in these files, if all fields except `attachedPictures` field are `nil`, audio decoding will encounter great issues after writing metadata
                    // so hereby always providing an empty `comment` if it is `nil`
                    file.metadata.comment = ""
                    try file.writeMetadata()
                }

                state = .fine
                print("Successfully written metadata to \(url)")

                continuation.resume()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    subscript<V>(extracting keyPath: WritableKeyPath<Metadata, Entry<V>>) -> MetadataBatchEditingEntry<V> {
        .init(keyPath: keyPath, metadatas: [self])
    }
}

// MARK: Extensions

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
