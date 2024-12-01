//
//  LyricsView.swift
//  Melodic Stamp
//
//  Created by Xinshao_Air on 2024/12/1.
//

import SwiftUI

struct LyricsView: View {
    @Bindable var lyrics: LyricsModel
    
    var body: some View {
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
                .scrollContentBackground(.hidden)
                .contentMargins(.top, 48)
            }
        }
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
        
    }
    
    @ViewBuilder private func rawLyricLine(line: RawLyricLine) -> some View {
        
    }
    
    @ViewBuilder private func lrcLyricLine(line: LRCLyricLine) -> some View {
        
    }
    
    @ViewBuilder private func ttmlLyricLine(line: TTMLLyricLine) -> some View {
        
    }
}
