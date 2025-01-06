//
//  SampleEnvironmentsPreviewModifier.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/12/31.
//

import CSFBAudioEngine
import SwiftUI

struct SampleEnvironmentsPreviewModifier: PreviewModifier {
    typealias Context = (
        floatingWindows: FloatingWindowsModel,
        windowManager: WindowManagerModel,
        fileManager: FileManagerModel,
        player: PlayerModel,
        playerKeyboardControl: PlayerKeyboardControlModel,
        metadataEditor: MetadataEditorModel
    )

    static func makeSharedContext() async throws -> Context {
        let floatingWindows = FloatingWindowsModel()
        let windowManager = WindowManagerModel()
        let fileManager = FileManagerModel()
        let player = PlayerModel(BlankPlayer())
        let playerKeyboardControl = PlayerKeyboardControlModel()
        let metadataEditor = MetadataEditorModel()

        metadataEditor.items = [samplePlayableItem]

        return (
            floatingWindows,
            windowManager,
            fileManager,
            player,
            playerKeyboardControl,
            metadataEditor
        )
    }

    func body(content: Content, context: Context) -> some View {
        content
            .environment(context.floatingWindows)
            .environment(context.windowManager)
            .environment(context.fileManager)
            .environment(context.player)
            .environment(context.playerKeyboardControl)
            .environment(context.metadataEditor)
    }
}

extension SampleEnvironmentsPreviewModifier {
    static var sampleURL: URL {
        .init(string: "https://example.com")!
    }

    static var sampleMetadata: Metadata {
        let metadata = AudioMetadata()

        metadata.attachPicture(NSImage.templateArtwork.attachedPicture(of: .other)!)

        return .init(url: sampleURL, from: metadata)
    }

    static var samplePlayableItem: Track {
        .init(
            url: sampleURL,
            metadata: sampleMetadata
        )
    }
}
