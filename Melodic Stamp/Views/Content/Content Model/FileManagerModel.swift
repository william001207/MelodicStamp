//
//  FileManagerModel.swift
//  Melodic Stamp
//
//  Created by KrLite on 2024/11/25.
//

import SwiftUI

enum FileOpenerPresentationStyle {
    case inCurrentPlaylist
    case replacingCurrentPlaylist
    case formNewPlaylist
}

enum FileAdderPresentationStyle {
    case toCurrentPlaylist
    case replacingCurrentPlaylist
    case formNewPlaylist
}

@Observable class FileManagerModel {
    var isFileOpenerPresented: Bool = false
    var fileOpenerPresentationStyle: FileOpenerPresentationStyle = .inCurrentPlaylist
    
    var isFileAdderPresented: Bool = false
    var fileAdderPresentationStyle: FileAdderPresentationStyle = .toCurrentPlaylist
}
