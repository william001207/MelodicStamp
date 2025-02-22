//
//  Bundle+Extensions.swift
//  MelodicStamp
//
//  Created by KrLite on 2024/11/10.
//

import Foundation

extension Bundle {
    enum Key: String {
        case appName = "CFBundleName"
        case displayName = "CFBundleDisplayName"
        case bundleID = "CFBundleIdentifier"
        case copyright = "NSHumanReadableCopyright"
        case appBuild = "CFBundleVersion"
        case appVersion = "CFBundleShortVersionString"
    }
}

extension Bundle {
    subscript(localized key: Key) -> String {
        localizedInfoDictionary?[key.rawValue] as? String ?? self[key]
    }

    subscript(_ key: Key) -> String {
        infoDictionary?[key.rawValue] as? String ?? "⚠️"
    }
}
