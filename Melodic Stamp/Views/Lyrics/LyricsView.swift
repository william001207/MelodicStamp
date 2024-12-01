//
//  LyricsView.swift
//  Melodic Stamp
//
//  Created by Xinshao_Air on 2024/12/1.
//

import SwiftUI

struct LyricsView: View {
    @Bindable var metadataEditor: MetadataEditorModel
    @Bindable var lyrics: LyricsModel
    
    @State private var lyricsType: LyricsType = .lrc
    
    var body: some View {
        Group {
            switch lyricsState {
            case .undefined:
                Color.red
            case .fine:
                TimelineView(.animation) { context in
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(alignment: .center, spacing: 10) {
                                lyricLines()
                            }
                            .padding()
                            
                            Spacer()
                                .frame(height: 72)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .scrollContentBackground(.hidden)
                        .contentMargins(.top, 48)
                    }
                }
            case .varied(let valueSetter):
                Color.blue
            }
        }
        .onChange(of: lyricsState) { oldValue, newValue in
            switch lyricsState {
            case .fine(let values):
                do {
                    try lyrics.load(type: lyricsType, string: values.current)
                } catch {
                    
                }
            default:
                break
            }
        }
        
        .toolbar {
            ToolbarItemGroup(placement: .confirmationAction) {
                LyricsToolbar(lyricsType: $lyricsType)
                    .background(.ultraThinMaterial)
                    .clipShape(.buttonBorder)
            }
        }
    }
    
    private var lyricsState: MetadataValueState<String?> {
        metadataEditor[extracting: \.lyrics]
    }
    
    @ViewBuilder private func lyricLines() -> some View {
        switch lyrics.storage {
        case .raw(let parser):
            ForEach(parser.lines) { line in
                rawLyricLine(line: line)
            }
        case .lrc(let parser):
            ForEach(parser.lines) { line in
                lrcLyricLine(line: line)
            }
        case .ttml(let parser):
            ForEach(parser.lines) { line in
                ttmlLyricLine(line: line)
            }
        case .none:
            EmptyView()
        }
    }
    
    @ViewBuilder private func rawLyricLine(line: RawLyricLine) -> some View {
    }
    
    @ViewBuilder private func lrcLyricLine(line: LRCLyricLine) -> some View {
        HStack {
            ForEach(line.tags) { tag in
                if !tag.type.isMetadata {
                    switch tag.type {
                    case .artist:
                        Text(tag.content)
                    case .album:
                        Text(tag.content)
                    case .title:
                        Text(tag.content)
                    case .author:
                        Text(tag.content)
                    case .creator:
                        Text(tag.content)
                    case .editor:
                        Text(tag.content)
                    case .version:
                        Text(tag.content)
                    default:
                        EmptyView()
                    }
                }
            }
            .foregroundStyle(.secondary)
            
            if line.isValid && !line.content.isEmpty {
                switch line.type {
                case .main:
                    Text(line.content)
                case .translation(let locale):
                    Text(locale)
                        .foregroundStyle(.placeholder)
                    
                    Text(line.content)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    @ViewBuilder private func ttmlLyricLine(line: TTMLLyricLine) -> some View {
    }
}
