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
//        ForEach(Array(player.lyricLines.enumerated()), id: \.offset) { index, line in
//            VStack(spacing: 2) {
//                let isCurrent = isCurrent(line: index)
//                if let stringF = line.stringF {
//                    Text(stringF)
//                        .font(isCurrent ? .headline : .body)
//                        .foregroundColor(isCurrent ? .blue : .primary)
//                }
//                
//                if let stringS = line.stringS {
//                    Text(stringS)
//                        .font(isCurrent ? .subheadline : .caption)
//                        .foregroundColor(isCurrent ? .gray : .secondary)
//                }
//            }
//            .id(index)
//        }
        
        switch lyrics.storage {
        case .raw(let parser):
            ForEach(parser.tags) { tag in
                lyricTag(tag: tag)
            }
            
            ForEach(parser.lines) { line in
                rawLyricLine(line: line)
            }
        case .lrc(let parser):
            ForEach(parser.tags) { tag in
                lyricTag(tag: tag)
            }
            
            ForEach(parser.lines) { line in
                lrcLyricLine(line: line)
            }
        case .ttml(let parser):
            ForEach(parser.tags) { tag in
                lyricTag(tag: tag)
            }
            
            ForEach(parser.lines) { line in
                ttmlLyricLine(line: line)
            }
        case .none:
            EmptyView()
        }
    }
    
    @ViewBuilder private func lyricTag(tag: LyricTag) -> some View {
        Text(tag.content)
    }
    
    @ViewBuilder private func rawLyricLine(line: RawLyricLine) -> some View {
        Text(line.content)
    }
    
    @ViewBuilder private func lrcLyricLine(line: LRCLyricLine) -> some View {
        Text(line.content)
    }
    
    @ViewBuilder private func ttmlLyricLine(line: TTMLLyricLine) -> some View {
        Text(line.content)
    }
}
