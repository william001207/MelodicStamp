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
    static var invalidInfo: String {
        "⚠️"
    }

    subscript(localized key: Key) -> String {
        guard let localizedInfoDictionary else { return Self.invalidInfo }
        return localizedInfoDictionary[key.rawValue] as? String ?? Self.invalidInfo
    }

    subscript(_ key: Key) -> String {
        guard let infoDictionary else { return Self.invalidInfo }
        return infoDictionary[key.rawValue] as? String ?? Self.invalidInfo
    }
}
