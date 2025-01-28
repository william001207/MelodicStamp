//
//  ApplicationResources.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/21.
//

import OSLog
import SwiftUI

protocol TypeNameReflectable {}

extension TypeNameReflectable {
    static var typeName: String {
        String(describing: Self.self)
    }

    static var logger: Logger {
        .init(subsystem: Bundle.main.bundleIdentifier ?? "Application", category: typeName)
    }

    var logger: Logger {
        Self.logger
    }
}

extension URL {
    static let github = URL(string: "https://github.com")!
    static let organization = github.appending(component: "Cement-Labs")
    static let repository = organization.appending(component: "Melodic-Stamp")
}

extension URL {
    static let playlists = musicDirectory.appending(component: Bundle.main[.appName]).appending(component: "Playlists")
}
