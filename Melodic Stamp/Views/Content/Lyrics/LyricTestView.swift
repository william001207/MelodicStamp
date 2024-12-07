//
//  LyricTestView.swift
//  Melodic Stamp
//
//  Created by Xinshao_Air on 2024/12/7.
//

import SwiftUI
import Foundation
import SwiftSoup

class TestLyricViewModel: ObservableObject {
    @Published var lyrics: [TestTtmlLyric] = []
    @Published var rawText: String = ""
    
    func parseLyrics() async {
        // 解析粘贴的歌词文本
        do {
            let parser = TestTTMLParser()
            let ttmlData = rawText.data(using: .utf8)!
            self.lyrics = try await parser.decodeTtml(data: ttmlData, coderType: .utf8)
        } catch {
            print("Error parsing TTML: \(error)")
        }
    }
}

struct LyricTestView: View {
    @ObservedObject var viewModel = TestLyricViewModel()

    var body: some View {
        VStack {
            // 粘贴歌词的文本框
            TextEditor(text: $viewModel.rawText)
                .padding()
                .border(Color.gray, width: 1)
                .frame(height: 200)

            // 解析按钮
            Button(action: {
                Task {
                    await viewModel.parseLyrics()
                }
            }) {
                Text("解析歌词")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.top, 10)

            // 显示解析后的歌词
            if !viewModel.lyrics.isEmpty {
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(viewModel.lyrics) { lyric in
                            VStack(alignment: .leading, spacing: 10) {
                                Text("索引: \(lyric.indexNum)")
                                    .foregroundColor(.orange) // 主歌词颜色

                                Text("位置: \(lyric.position)")
                                    .foregroundColor(.orange) // 主歌词颜色

                                HStack( spacing: 0) {
                                    // 主歌词
                                    if let mainLyrics = lyric.mainLyric {
                                        ForEach(mainLyrics, id: \.beginTime) { subLyric in
                                            Text(subLyric.text)
                                                .font(.title2.bold())
                                                .foregroundColor(.primary) // 主歌词颜色
                                        }
                                    }
                                }

                                // 主歌词的翻译和罗马音
                                if let translation = lyric.translation {
                                    Text("翻译: \(translation)")
                                        .foregroundColor(.blue) // 翻译颜色
                                }

                                if let roman = lyric.roman {
                                    Text("罗马音: \(roman)")
                                        .foregroundColor(.purple) // 罗马拼音颜色
                                }

                                // 背景歌词
                                if let bgLyric = lyric.bgLyric {
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("背景歌词:")
                                            .foregroundColor(.gray)
                                            .font(.headline)
                                        if let subLyrics = bgLyric.subLyric {
                                            // 合并所有子歌词的文本
                                            let combinedBgText = subLyrics
                                                .sorted(by: { $0.beginTime < $1.beginTime })
                                                .map { $0.text }
                                                .joined(separator: " ")

                                            Text(combinedBgText)
                                                .foregroundColor(.gray) // 背景歌词颜色
                                                .font(.body)
                                        }

                                        // 背景歌词的翻译和罗马音
                                        if let bgTranslation = bgLyric.translation {
                                            Text("背景翻译: \(bgTranslation)")
                                                .foregroundColor(.blue) // 翻译颜色
                                        }

                                        if let bgRoman = bgLyric.roman {
                                            Text("背景罗马音: \(bgRoman)")
                                                .foregroundColor(.purple) // 罗马拼音颜色
                                        }
                                    }
                                    .padding(.top, 5)
                                }

                                // 显示开始和结束时间
                                Text("开始时间: \(String(format: "%.2f", lyric.beginTime)) 秒")
                                    .font(.caption)
                                    .foregroundColor(.green)

                                Text("结束时间: \(String(format: "%.2f", lyric.endTime)) 秒")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                            .padding(.vertical)
                        }
                    }
                }
                .padding()
                .border(Color.gray, width: 1)
                .frame(height: 500, alignment: .center)
            } else {
                Text("请粘贴TTML格式歌词并点击解析")
                    .foregroundColor(.gray)
                    .italic()
                    .padding()
            }
        }
        .padding()
        .frame(height: 800, alignment: .center)
    }
}


#Preview {
    LyricTestView()
}
