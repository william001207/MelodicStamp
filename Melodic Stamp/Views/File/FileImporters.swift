//
//  FileImporters.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/11/30.
//

import SwiftUI

struct FileImporters: View {
    @Bindable var fileManager: FileManagerModel
    @Bindable var player: PlayerModel
    
    var body: some View {
        Color.clear
            .fileImporter(
                isPresented: $fileManager.isFileOpenerPresented,
                allowedContentTypes: allowedContentTypes
            ) { result in
                switch result {
                case .success(let url):
                    fileManager.open(url: url, using: player)
                case .failure:
                    break
                }
            }
        
        Color.clear
            .fileImporter(
                isPresented: $fileManager.isFileAdderPresented,
                allowedContentTypes: allowedContentTypes,
                allowsMultipleSelection: true
            ) { result in
                switch result {
                case .success(let urls):
                    fileManager.add(urls: urls, to: player)
                case .failure:
                    break
                }
            }
    }
}
