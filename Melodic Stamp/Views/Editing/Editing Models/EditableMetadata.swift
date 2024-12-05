//
//  EditableMetadata.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/11/24.
//

@preconcurrency import CSFBAudioEngine
import SwiftUI

// MARK: - Modifiable

protocol Modifiable {
    var isModified: Bool { get }
}

// MARK: - Restorable

protocol Restorable: Equatable, Modifiable {
    associatedtype V: Equatable
    
    var current: V { get set }
    var initial: V { get set }
    
    mutating func restore()
    mutating func apply()
}

extension Restorable {
    var isModified: Bool {
        current != initial
    }
    
    mutating func restore() {
        current = initial
    }
    
    mutating func apply() {
        initial = current
    }
}

// MARK: - Additional Metadata

struct NonHashableWrapper: Hashable {
    let description: String
    
    init(_ value: Any) {
        self.description = String(describing: value)
    }
}

typealias AdditionalMetadata = [AnyHashable: AnyHashable]

extension AdditionalMetadata {
    init(_ dictionary: [AnyHashable: Any]) {
        self = dictionary.reduce(into: [AnyHashable: AnyHashable]()) { result, pair in
            let (key, value) = pair
            if let hashableValue = value as? AnyHashable {
                result[key] = hashableValue
            } else {
                result[key] = NonHashableWrapper(value)
            }
        }
    }
    
//    var asAny: [AnyHashable: Any] {
//        self.reduce(into: [AnyHashable: Any]()) { result, pair in
//            let (key, value) = pair
//            if let wrapper = value as? NonHashableWrapper {
//                result[key] = wrapper.description // TODO: replace this with recovery logic if needed
//            } else {
//                result[key] = value
//            }
//        }
//    }
}

// MARK: - Metadata Value

@Observable final class EditableMetadataValue<V: Hashable & Equatable>: Restorable {
    var current: V {
        didSet {
            print("Set current value to \(current)")
        }
    }
    var initial: V {
        didSet {
            print("Set initial value to \(current)")
        }
    }
    
    init(_ value: V) {
        self.current = value
        self.initial = value
    }
}

extension EditableMetadataValue: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(current)
        hasher.combine(initial)
    }
}

extension EditableMetadataValue: Equatable {
    static func == (lhs: EditableMetadataValue<V>, rhs: EditableMetadataValue<V>) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

// MARK: - Metadata

@Observable final class EditableMetadata: Identifiable, Sendable {
    typealias Value = EditableMetadataValue
    
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
    
    var attachedPictures: Value<Set<AttachedPicture>>!
    
    var title: Value<String?>!
    var titleSortOrder: Value<String?>!
    var artist: Value<String?>!
    var artistSortOrder: Value<String?>!
    var composer: Value<String?>!
    var composerSortOrder: Value<String?>!
    var genre: Value<String?>!
    var genreSortOrder: Value<String?>!
    var bpm: Value<Int?>!
    
    var albumTitle: Value<String?>!
    var albumTitleSortOrder: Value<String?>!
    var albumArtist: Value<String?>!
    var albumArtistSortOrder: Value<String?>!
    
    var trackNumber: Value<Int?>!
    var trackTotal: Value<Int?>!
    var discNumber: Value<Int?>!
    var discTotal: Value<Int?>!
    
    var comment: Value<String?>!
    var grouping: Value<String?>!
    var isCompilation: Value<Bool?>!
    
    var isrc: Value<String?>!
    var lyrics: Value<String?>!
    var mcn: Value<String?>!
    
    var musicBrainzRecordingID: Value<String?>!
    var musicBrainzReleaseID: Value<String?>!
    
    var rating: Value<Int?>!
    var releaseDate: Value<String?>!
    
    var replayGainAlbumGain: Value<Double?>!
    var replayGainAlbumPeak: Value<Double?>!
    var replayGainTrackGain: Value<Double?>!
    var replayGainTrackPeak: Value<Double?>!
    var replayGainReferenceLoudness: Value<Double?>!
    
    var additional: Value<AdditionalMetadata?>!

    init?(url: URL) {
        self.state = .loading
        self.url = url

        Task.detached {
            try await self.update()
            self.state = .fine
        }
    }
    
    fileprivate var restorables: [any Restorable] {
        guard state.isLoaded else { return [] }
        return [
            attachedPictures,
            title, titleSortOrder, artist, artistSortOrder, composer, composerSortOrder, genre, genreSortOrder, bpm,
            albumTitle, albumTitleSortOrder, albumArtist, albumArtistSortOrder,
            trackNumber, trackTotal, discNumber, discTotal,
            comment, grouping, isCompilation,
            isrc, lyrics, mcn,
            musicBrainzRecordingID, musicBrainzReleaseID,
            rating, releaseDate,
            replayGainAlbumGain, replayGainAlbumPeak, replayGainTrackGain, replayGainTrackPeak, replayGainReferenceLoudness
        ]
    }
}

extension EditableMetadata {
    fileprivate func load(
        coverImages: Set<AttachedPicture> = [],
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
        musicBrainzRecordingID: String? = nil, musicBrainzReleaseID: String? = nil,
        rating: Int? = nil,
        releaseDate: String? = nil,
        replayGainAlbumGain: Double? = nil, replayGainAlbumPeak: Double? = nil,
        replayGainTrackGain: Double? = nil, replayGainTrackPeak: Double? = nil,
        replayGainReferenceLoudness: Double? = nil,
        additional: AdditionalMetadata? = nil
    ) {
        self.attachedPictures = .init(coverImages)
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
            coverImages: metadata?.attachedPictures ?? [],
            title: metadata?.title, titleSortOrder: metadata?.titleSortOrder,
            artist: metadata?.artist, artistSortOrder: metadata?.artistSortOrder,
            composer: metadata?.composer, composerSortOrder: metadata?.composerSortOrder,
            genre: metadata?.genre, genreSortOrder: metadata?.genreSortOrder,
            bpm: metadata?.bpm,
            albumTitle: metadata?.albumTitle, albumTitleSortOrder: metadata?.albumTitleSortOrder,
            albumArtist: metadata?.albumArtist, albumArtistSortOrder: metadata?.albumArtistSortOrder,
            trackNumber: metadata?.trackNumber, trackTotal: metadata?.trackTotal,
            discNumber: metadata?.discNumber, discTotal: metadata?.discTotal,
            comment: metadata?.comment,
            grouping: metadata?.grouping,
            isCompilation: metadata?.isCompilation,
            isrc: metadata?.isrc,
            lyrics: metadata?.lyrics,
            mcn: metadata?.mcn,
            musicBrainzRecordingID: metadata?.musicBrainzRecordingID, musicBrainzReleaseID: metadata?.musicBrainzReleaseID,
            rating: metadata?.rating, releaseDate: metadata?.releaseDate,
            replayGainAlbumGain: metadata?.replayGainAlbumGain, replayGainAlbumPeak: metadata?.replayGainAlbumPeak,
            replayGainTrackGain: metadata?.replayGainTrackGain, replayGainTrackPeak: metadata?.replayGainTrackPeak,
            replayGainReferenceLoudness: metadata?.replayGainReferenceLoudness,
            additional: metadata?.additionalMetadata.map(AdditionalMetadata.init(_:))
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
        metadata.replayGainReferenceLoudness = replayGainReferenceLoudness.current
        metadata.additionalMetadata = additional.current
        
        attachedPictures.current.forEach(metadata.attachPicture(_:))
        
        return metadata
    }
}

extension EditableMetadata {
    var isModified: Bool {
        guard self.state.isLoaded else { return false }
        return !restorables.filter(\.isModified).isEmpty
    }

    func restore() {
        guard self.state.isLoaded else { return }
        for var restorable in self.restorables {
            restorable.restore()
        }
    }

    func apply() {
        guard self.state.isLoaded else { return }
        for var restorable in self.restorables {
            restorable.apply()
        }
    }

    func update() async throws {
        try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self else { return continuation.resume() }
            guard url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }

            do {
                let file = try AudioFile(readingPropertiesAndMetadataFrom: url)
                properties = file.properties
                load(from: file.metadata)
                state = .fine
                switch state {
                case .loading:
                    print("Loaded metadata from \(url)")
                default:
                    print("Updated metadata from \(url)")
                }

                continuation.resume()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    func write() async throws {
        try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self, state.isEditable, isModified else { return continuation.resume() }
            guard url.startAccessingSecurityScopedResource() else { return }
            defer { self.url.stopAccessingSecurityScopedResource() }

            do {
                state = .saving
                apply()
                print("Started writing metadata to \(url)")

                let file = try AudioFile(url: url)
                file.metadata = pack()
                try file.writeMetadata()

                state = .fine
                print("Successfully written metadata to \(url)")

                continuation.resume()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    subscript<V>(extracting keyPath: WritableKeyPath<EditableMetadata, Value<V>>) -> BatchEditableMetadataValue<V> {
        .init(keyPath: keyPath, editableMetadatas: [self])
    }
}

extension EditableMetadata: Equatable {
    static func == (lhs: EditableMetadata, rhs: EditableMetadata) -> Bool {
        lhs.id == rhs.id
    }
}

extension EditableMetadata: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Metadata Value (Batch Editing)

@Observable final class BatchEditableMetadataValue<V: Hashable & Equatable>: Identifiable {
    typealias Value = EditableMetadataValue
    
    let keyPath: WritableKeyPath<EditableMetadata, Value<V>>
    let editableMetadatas: Set<EditableMetadata>

    init(keyPath: WritableKeyPath<EditableMetadata, Value<V>>, editableMetadatas: Set<EditableMetadata>) {
        self.keyPath = keyPath
        self.editableMetadatas = editableMetadatas
    }

    var current: V {
        get {
            editableMetadatas.first![keyPath: keyPath].current
        }

        set {
            editableMetadatas.forEach { $0[keyPath: keyPath].current = newValue }
        }
    }

    private(set) var initial: V {
        get {
            editableMetadatas.first![keyPath: keyPath].initial
        }
        
        set {
            editableMetadatas.forEach { $0[keyPath: keyPath].initial = newValue }
        }
    }

    var projectedValue: Binding<V> {
        Binding(get: {
            self.current
        }, set: { newValue in
            self.current = newValue
        })
    }

    var isModified: Bool {
        current != initial
    }

    func restore() {
        current = initial
    }

    func apply() {
        initial = current
    }

    subscript(isModified keyPath: KeyPath<V, some Equatable>) -> Bool {
        current[keyPath: keyPath] != initial[keyPath: keyPath]
    }
}

// MARK: - Metadata Values (Batch Editing)

@Observable final class BatchEditableMetadataValues<V: Hashable & Equatable>: Identifiable {
    typealias Value = EditableMetadataValue
    
    let keyPath: WritableKeyPath<EditableMetadata, Value<V>>
    let editableMetadatas: Set<EditableMetadata>

    init(keyPath: WritableKeyPath<EditableMetadata, Value<V>>, editableMetadatas: Set<EditableMetadata>) {
        self.keyPath = keyPath
        self.editableMetadatas = editableMetadatas
    }

    var values: [BatchEditableMetadataValue<V>] {
        editableMetadatas.map { $0[extracting: keyPath] }
    }

    var isModified: Bool {
        !values.filter(\.isModified).isEmpty
    }

    func revertAll() {
        values.forEach { $0.restore() }
    }

    func applyAll() {
        values.forEach { $0.apply() }
    }

    subscript(isModified keyPath: KeyPath<V, some Equatable>) -> Bool {
        !values.filter(\.[isModified: keyPath]).isEmpty
    }
}
